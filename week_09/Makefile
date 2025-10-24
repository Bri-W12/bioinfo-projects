## Makefile for Week 9

# Accession number for the reference genome
RF=NC_007793.1

# Name for the reference genome
GENOME_NAME=Staphaureus

# Bioproject ID
PRR=PRJNA887926

# SRR Number
SRR=SRR21835898

# Output directory for SRR reads
DIR=reads

# Output directory for FastQC results
DIR2=qc

# Reference fasta
REF=${GENOME_NAME}.fna

# Read 1
R1=reads/${SRR}_1.fastq

# Read 2
R2=reads/${SRR}_2.fastq

# Output BAM file
BAM=bam/${SRR}.bam

# Output directory for BAM, bedgraph, and bigwig files
BAM_DIR=bam

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
	bio fetch ${RF} -format fasta > ${GENOME_NAME}.fna
	bio fetch ${RF} -format gff > ${GENOME_NAME}.gff

# Get metadata for BioProject
get_bioproject:
	@echo "Fetching metadata for bioproject ${PRR}"
	bio search ${PRR} -H --csv > metadata.csv

# Get data for one SRR
get_srr:
	@echo "Fetching SRR data for ${SRR}"
	mkdir -p ${DIR}
	bio fetch ${SRR}

# Download 10000 reads from SRR and get stats
download_reads:
	@echo "Downloading 10000 reads from ${SRR} and getting stats"
	fastq-dump -X 10000 --outdir reads --split-files $(SRR)
	seqkit stats reads/$(SRR)_1.fastq reads/$(SRR)_2.fastq > reads/$(SRR)_stats.txt

# Run FastQC on the reads
fastqc:
	@echo "Running FastQC on all reads"
	mkdir -p ${DIR2}
	fastqc -o ${DIR2} reads/${SRR}_1.fastq reads/${SRR}_2.fastq

# Index the reference genome for alignment
index_genome:
	@echo "Indexing reference genome ${REF}"
	bwa index ${REF}
	samtools faidx ${REF}

# Align the reads and convert to BAM
align:
	@echo "Aligning reads to reference genome and converting to BAM"
	mkdir -p $(dir ${BAM})
	bwa mem -t 4 ${REF} ${R1} ${R2} | samtools sort  > ${BAM}
	samtools index ${BAM}

# Generate alignment statistics
alignment_stats:
	@echo "Generating alignment statistics for ${BAM}"
	samtools flagstat ${BAM} > ${BAM}_stats.txt
	cat ${BAM}_stats.txt

# Generate temporary bedgraph file
bam_to_bedgraph:
	@echo "Generating bedgraph file for ${BAM}"
	LC_ALL=C bedtools genomecov -ibam ${BAM} -split -bg | sort -k1,1 -k2,2n > ${BG}

# Turn bedgraph file into a bigWig file
bedgraph_to_bigwig: 
	@echo "Converting bedgraph ${BG} to bigWig ${BW}"
	bedGraphToBigWig ${BG} ${REF}.fai ${BW}

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf ${DIR} ${DIR2} bam/*.bedgraph bam/*.bw bam/*.bam bam/*.bai metadata.csv ${GENOME_NAME}.fna ${GENOME_NAME}.gff

