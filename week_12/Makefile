## Makefile for Week 12

# Set the URL of the reference genome from the README
REF_URL=https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/GRCh38/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta.gz

# Download the reference genome 
REF_FULL=refs/GRCh38.fasta.gz

# Unzipped reference genome
REF_FULL_unzipped=refs/GRCh38.fasta

# Chromosome of interest
CHR=chr12

# A subset of the reference genome for the region of interest
REF_CHR=refs/${CHR}.fasta

# Set the URL of the BAM file from Illumina sequencing
BAM_URL_Illumina=https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/BCM_Illumina-WGS_20240313/HG008-N-D_Illumina_169x_GRCh38-GIABv3.bam

# Set the URL of the BAM file from PacBio Revio sequencing
BAM_URL_PacBio=https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/PacBio_Revio_20240125/HG008-N-P_PacBio-HiFi-Revio_20240125_35x_GRCh38-GIABv3.bam

# Output BAM files
BAM_Illumina=bam/HG008_Illumina.bam
BAM_PacBio=bam/HG008_PacBio.bam

# Set the region of interest 
REGION=chr12:25,205,246-25,250,936

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

#--------- DO NOT EDIT BELOW THIS LINE --------

# Download the reference genome
get_ref:
	@echo "Downloading reference genome from ${REF_URL}"
	mkdir -p refs
	curl -L ${REF_URL} > ${REF_FULL}
	@echo "Unzipping reference genome"
	gunzip -f ${REF_FULL}

# Index the reference genome for use with samtools.
index_ref:
	@echo "Indexing reference genome ${REF_FULL_unzipped}"
	samtools faidx ${REF_FULL_unzipped}

# Extract the reads for the region of interest from the Illumina BAM file
extract_illumina:
	@echo "Extracting reads for region ${REGION} from Illumina BAM file"
	mkdir -p bam
	samtools view -b ${BAM_URL_Illumina} ${REGION} > ${BAM_Illumina}

# Extract the reads for the region of interest from the PacBio BAM file
extract_pacbio:
	@echo "Extracting reads for region ${REGION} from PacBio BAM file"
	samtools view -b ${BAM_URL_PacBio} ${REGION} > ${BAM_PacBio}

# Index the extracted BAM files
index_bams: 
	@echo "Indexing extracted BAM files"
	samtools index ${BAM_Illumina}
	samtools index ${BAM_PacBio}

# Generate alignment statistics for both BAM files
alignment_stats:
	@echo "Generating alignment statistics for Illumina BAM file"
	samtools flagstat ${BAM_Illumina} > bam/HG008_Illumina_stats.txt
	@echo "Generating alignment statistics for PacBio BAM file"
	samtools flagstat ${BAM_PacBio} > bam/HG008_PacBio_stats.txt

# Compare read depth between Illumina and PacBio BAM files
compare_depth:
	@echo "Comparing read depth between Illumina and PacBio BAM files"
	samtools depth ${BAM_Illumina} > bam/illumina.depth
	samtools depth ${BAM_PacBio} > bam/pacbio.depth

# Determine average read depth for both BAM files
average_depth:
	@echo "Calculating average read depth for Illumina BAM file"
	awk 'BEGIN {sum=0} {sum += $$3} END {print "Average depth:", sum/NR}' bam/illumina.depth
	@echo "Calculating average read depth for PacBio BAM file"
	awk 'BEGIN {sum=0} {sum += $$3} END {print "Average depth:", sum/NR}' bam/pacbio.depth

