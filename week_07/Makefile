## Makefile for Week 7

# Accession number for the reference genome
RF=NC_007793.1

# Bioproject ID
PRR=PRJNA887926

# SRR Number
SRR=SRR21835896

# Output directory for SRR reads
DIR=reads

# Output directory for FastQC results
DIR2=qc

# Read 1
R1=reads/${SRR}_1.fastq

# Read 2
R2=reads/${SRR}_2.fastq

# Reference fasta
REF=${RF}.fna

# Output BAM file
BAM=bam/${SRR}.bam

# The temporary bedgraph file
BG=bam/${SRR}.bedgraph

# The BW wiggle file
BW=bam/${SRR}.bw

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
	bio fetch ${RF} -format fasta > ${RF}.fna
	bio fetch ${RF} -format gff > ${RF}.gff

# Get data from Bioproject ID (fetch all SRRs)
get_bioproject:
	mkdir -p ${DIR}
	for srr in $$(esearch -db sra -query ${PRR} | efetch -format runinfo | cut -d ',' -f 1 | grep SRR); do \
		echo "Fetching $$srr"; \
		bio fetch $$srr; \
	done

# Get data from one SRR
get_srr:
	mkdir -p ${DIR}
	bio fetch ${SRR}

# Download first 1000 reads from SRR and get stats
download_reads:
	mkdir -p reads
	fastq-dump -X 1000 -F --outdir reads --split-files ${SRR}
	@if [ -f reads/${SRR}_1.fastq ] && [ -f reads/${SRR}_2.fastq ]; then \
		echo "Detected paired-end reads"; \
		seqkit stats reads/${SRR}_1.fastq reads/${SRR}_2.fastq > reads/${SRR}_stats.txt; \
	elif [ -f reads/${SRR}.fastq ]; then \
		echo "Detected single-end reads"; \
		seqkit stats reads/${SRR}.fastq > reads/${SRR}_stats.txt; \
	else \
		echo "Error: No FASTQ files found for ${SRR}"; \
		ls -lh reads/; \
		exit 1; \
	fi
	cat reads/${SRR}_stats.txt

# Run FastQC on the reads 
fastqc:
	mkdir -p ${DIR2}
	fastqc -o ${DIR2} reads/${SRR}_1.fastq reads/${SRR}_2.fastq

# Index the reference genome for alignment
index_genome:
	bwa index ${RF}.fna
	samtools faidx ${RF}.fna

# Align the reads and convert to BAM
align:
	mkdir -p bam
	@if [ -f reads/${SRR}_1.fastq ] && [ -f reads/${SRR}_2.fastq ]; then \
		echo "Detected paired-end reads for alignment"; \
		bwa mem -t 4 ${REF} reads/${SRR}_1.fastq reads/${SRR}_2.fastq | samtools sort -o bam/${SRR}.bam; \
	elif [ -f reads/${SRR}.fastq ]; then \
		echo "Detected single-end reads for alignment"; \
		bwa mem -t 4 ${REF} reads/${SRR}.fastq | samtools sort -o bam/${SRR}.bam; \
	else \
		echo "Error: No FASTQ files found for ${SRR}"; \
		ls -lh reads/; \
		exit 1; \
	fi
	samtools index bam/${SRR}.bam

# Generate alignment statistics
alignment_stats:
	samtools flagstat ${BAM} > ${BAM}_stats.txt
	cat ${BAM}_stats.txt

# Generate temporary bedgraph file
bam_to_bedgraph:
	LC_ALL=C; bedtools genomecov -ibam  ${BAM} -split -bg | \
	sort -k1,1 -k2,2n > ${BG}

# Turn bedgraph file into a bigWig file
bedgraph_to_bigwig: 
	bedGraphToBigWig ${BG} ${REF}.fai ${BW}

# Samtools depth to calculate area with highest coverage
depth:
	-samtools depth ${BAM} | sort -k3nr | head -n 1

# Clean up generated files
clean:
	rm -rf ${REF} ${R1} ${R2} ${BAM} ${BAM}.bai

# Run everything
all: get_genome get_srr download_reads fastqc index_genome align alignment_stats bam_to_bedgraph bedgraph_to_bigwig depth clean

# Shortcut to run everything
run: all
