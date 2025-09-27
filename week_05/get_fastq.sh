# make scripts behave a little better
set -uexo pipefail

# Bioproject ID
PRR=PRJNA887926

# SRR Number
SRR=SRR21835896

# DRR Number (Nanopore Dataset)
DRR=DRR660590



-----------------------------

# Obtain run metadata based on PRJN number
bio fetch $PRR

# Obtain run metadata based on SRR number
bio fetch $SRR

# Make output directory
mkdir -p reads

# Download a subset of 1000 reads based on SRR number
fastq-dump -X 1000 -F --outdir reads --split-files $SRR

# Basic read statistics
seqkit stats reads/${SRR}_1.fastq reads/${SRR}_2.fastq > reads/${SRR}_stats.txt

# View the statistics
cat reads/${SRR}_stats.txt

# Download subset of reads for 10x coverage
fastq-dump -X 290000 -F --outdir reads --split-files $SRR

# Generate statistics on 10x coverage
seqkit stats reads/${SRR}_1.fastq reads/${SRR}_2.fastq > reads/${SRR}_stats.txt

# View the statistics
cat reads/${SRR}_stats.txt

# Create output directory for FastQC results
mkdir -p qc

# Run FastQC on the reads
fastqc reads/${SRR}_1.fastq reads/${SRR}_2.fastq -o qc

# Check output folder
ls qc/

# Open HTML report in browser
xdg-open qc/${SRR}_1_fastqc.html
xdg-open qc/${SRR}_2_fastqc.html

# Create output directory for Nanopore DRR Dataset
mkdir -p nanopore

# Download Nanopore DRR Dataset
fastq-dump -X 5000 -F --outdir nanopore $DRR

# Generate statistics on Nanopore reads
seqkit stats nanopore/${DRR}.fastq > nanopore/${DRR}_stats.txt

# View the statistics
cat nanopore/${DRR}_stats.txt

# Run FastQC on the Nanopore reads
fastqc nanopore/${DRR}.fastq -o qc

# Open HTML report in browser
xdg-open qc/${DRR}_fastqc.html

