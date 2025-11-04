## Makefile for Week 10

# Accession number for the reference genome
RF=NC_007793.1

# Name for the reference genome
GENOME_NAME=Staphaureus

# Bioproject ID
PRR=PRJNA887926

# Output directory for SRR reads
DIR=reads

# Output directory for FastQC results
DIR2=qc

# Reference fasta
REF=${GENOME_NAME}.fna

# Read 1
R1=reads/${SAMPLE}_1.fastq

# Read 2
R2=reads/${SAMPLE}_2.fastq

# Flags for the mpileup command
F1=-d 100 --annotate 'INFO/AD,FORMAT/DP,FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/SP'

# Flags for the call command
F2=--ploidy 2 --annotate 'FORMAT/GQ'

# Output BAM file
BAM=bam/${SAMPLE}.bam

# Output directory for BAM, bedgraph, and bigwig files
BAM_DIR=bam

# The temporary bedgraph and bigwig files
BG = ${BAM_DIR}/${SRR}.bedgraph
BW = ${BAM_DIR}/${SRR}.bw

# Variant Call File
VCF = variants/${SAMPLE}.vcf.gz

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
	mv ${DIR}/${SRR}_1.fastq ${DIR}/${SAMPLE}_1.fastq
	mv ${DIR}/${SRR}_2.fastq ${DIR}/${SAMPLE}_2.fastq
	seqkit stats ${DIR}/${SAMPLE}_1.fastq ${DIR}/${SAMPLE}_2.fastq > ${DIR}/${SAMPLE}_stats.txt

# Run FastQC on the reads
fastqc:
	@echo "Running FastQC on all reads"
	mkdir -p ${DIR2}
	fastqc -o ${DIR2} ${DIR}/${SAMPLE}_1.fastq ${DIR}/${SAMPLE}_2.fastq

# Index the reference genome for alignment
index_genome:
	@echo "Indexing reference genome ${REF}"
	bwa index ${REF}
	samtools faidx ${REF}

# Align the reads to the reference genome and generate alignment stats
align:
	@echo "Aligning reads for sample ${SAMPLE} to reference genome ${REF}"
	mkdir -p $(dir ${BAM})
	make -f src/run/bwa.mk \
		IDX=${REF} \
		SM=${SAMPLE} \
		REF=${REF} \
		R1=${R1} \
		R2=${R2} \
		BAM=${BAM} \
		run stats

# Generate temporary bedgraph file
bam_to_bedgraph:
	@echo "Generating bedgraph file for ${BAM}"
	LC_ALL=C bedtools genomecov -ibam ${BAM} -split -bg | sort -k1,1 -k2,2n > ${BG}

# Turn bedgraph file into a bigWig file
bedgraph_to_bigwig: 
	@echo "Converting bedgraph ${BG} to bigWig ${BW}"
	bedGraphToBigWig ${BG} ${REF}.fai ${BW}

# Variant calling
vcf:
	@echo "Calling variants for ${BAM} against reference ${REF}"
	make -f src/run/bcftools.mk REF=${REF} BAM=${BAM} VCF=${VCF} run

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf ${DIR} ${DIR2} bam/*.bedgraph bam/*.bw bam/*.bam bam/*.bai metadata.csv ${GENOME_NAME}.fna ${GENOME_NAME}.gff

