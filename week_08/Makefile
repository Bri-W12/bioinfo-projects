## Makefile for Week 8

# Accession number for the reference genome
RF=NC_007793.1

# Bioproject ID
PRR=PRJNA887926

# Output directory for SRR reads
DIR=reads

# Output directory for FastQC results
DIR2=qc

# Reference fasta
REF=${RF}.fna

# The temporary bedgraph and bigwig files
BG = ${BAM_DIR}/${SRR}.bedgraph
BW = ${BAM_DIR}/${SRR}.bw

# Add this to every Makefile.

# Set the shell the commands run in.
SHELL = bash

# Execute all commands in a single shell.
.ONESHELL:

# Run the shell with strict error checking.
.SHELLFLAGS = -eu -o pipefail -c

# Delete target files if the command fails.
.DELETE_ON_ERROR:

# Warn if a variable is not defined.
MAKEFLAGS += --warn-undefined-variables

# Disable built-in rules.
MAKEFLAGS += --no-builtin-rules

# -------- DO NOT EDIT BELOW THIS LINE --------

# Get reference genome in fasta and gff format
get_genome:
	@echo "Fetching genome ${RF} in fasta and gff format"
	bio fetch ${RF} -format fasta > ${RF}.fna
	bio fetch ${RF} -format gff > ${RF}.gff

# Get metadata for BioProject
get_bioproject:
	@echo "Fetching metadata for bioproject ${PRR}"
	bio search ${PRR} -H --csv > metadata.csv

# Previewing sample names
get_sample_names: 
	@echo "Previewing sample names from metadata.csv"
	cat metadata.csv | cut -f 1,3 -d , | head

# Create design.csv and connect SRR numbers to Sample names
get_design:
	@echo "Connecting SRR numbers to Sample names in design.csv"
	cat design.csv | parallel -j 1 --colsep , --header : \
	make all SRR={SRR_numbers} SAMPLE={sample_names}

# Get data from SRRs using parallel
get_srrs:
	@echo "Fetching SRR data for each SRR in design.csv"
	mkdir -p ${DIR}
	cat design.csv | tail -n +2 | parallel -j 1 --colsep , --header : \
	'bio fetch {SRR_numbers} -o reads/{SRR_numbers}_{sample_names}'

# Download 10000 reads from each SRR and get stats
download_reads:
	@echo "Downloading 10000 reads for each SRR"
	mkdir -p ${DIR}
	cat design.csv | tail -n +2 | parallel -j 1 --colsep , --header : \
		'echo "Fetching {SRR_numbers} ({sample_names})"; \
		 fastq-dump -X 10000 -F --outdir reads --split-files {SRR_numbers}; \
		 seqkit stats reads/{SRR_numbers}_1.fastq reads/{SRR_numbers}_2.fastq > reads/{SRR_numbers}_{sample_names}_stats.txt; \
		 sleep 5'
	cat reads/*_stats.txt

# Run FastQC on the reads 
fastqc:
	@echo "Running FastQC on all reads"
	mkdir -p ${DIR2}
	cat design.csv | tail -n +2 | parallel -j 1 --colsep , --header : \
	'fastqc -o ${DIR2} reads/{SRR_numbers}_1.fastq reads/{SRR_numbers}_2.fastq'

# Index the reference genome for alignment
index_genome:
	@echo "Indexing reference genome ${REF}"
	bwa index ${REF}
	samtools faidx ${REF}

# Align the reads and convert to BAM
align:
	@echo "Aligning reads to reference genome and converting to BAM"
	mkdir -p bam
	cat design.csv | tail -n +2 | parallel --colsep , --header : \
	'bwa mem -t 4 ${REF} reads/{SRR_numbers}_1.fastq reads/{SRR_numbers}_2.fastq | \
	samtools sort > bam/{SRR_numbers}.bam; \
	samtools index bam/{SRR_numbers}.bam'

# Generate alignment statistics
alignment_stats:
	@echo "Generating alignment statistics for all BAM files"
	cat design.csv | tail -n +2 | parallel --colsep , --header : \
	'samtools flagstat bam/{SRR_numbers}.bam > bam/{SRR_numbers}_bam_stats.txt; \
	cat bam/{SRR_numbers}_bam_stats.txt'

# Generate BedGraph coverage files
bam_to_bedgraph:
	@echo "Generating bedGraph coverage files for all BAMs"
	cat design.csv | tail -n +2 | parallel --colsep , --header : \
	'bedtools genomecov -ibam bam/{SRR_numbers}.bam -split -bg | \
	sort -k1,1 -k2,2n > bam/{SRR_numbers}.bedgraph'
	
# Convert BedGraph to BigWig
bedgraph_to_bigwig:
	@echo "Converting bedGraph files to BigWig format"
	cat design.csv | tail -n +2 | parallel --colsep , --header : \
	'bedGraphToBigWig bam/{SRR_numbers}.bedgraph ${REF}.fai bam/{SRR_numbers}.bw'

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf bam/*.bam bam/*.bai bam/*.bedgraph bam/*.bw
	rm -rf reads/*.fastq reads/*_stats.txt
	rm -rf qc/*.html qc/*.zip
	rm -f ${REF}.amb ${REF}.ann ${REF}.bwt ${REF}.pac ${REF}.sa ${REF}.fai

# Per sample workflow (runs for each SRR)
per_sample: get_srrs download_reads fastqc align alignment_stats bam_to_bedgraph bedgraph_to_bigwig

# Run everything
all: get_genome get_bioproject get_sample_names get_design

# Shortcut to run everything
run: all
