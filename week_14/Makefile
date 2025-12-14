## Makefile for Week 14

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

# Output BAM file
BAM=bam/${SAMPLE}.bam

# Output directory for BAM, bedgraph, and bigwig files
BAM_DIR=bam

# The temporary bedgraph and bigwig files
BG = ${BAM_DIR}/${SAMPLE}.bedgraph
BW = ${BAM_DIR}/${SAMPLE}.bw

# Ensembl reference genome
RF_ENSEMBL=usa300.fna

# Ensembl GFF3 file
GFF_ENSEMBL=usa300.gff3

# Output BAM file for Ensembl alignment
BAM_ENSEMBL=bam/ensembl/${SAMPLE}.bam

# Output directory for Ensembl Featurecounts
ENSEMBL_DIR=counts_ensembl

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

# Converting GFF to GTF
gff_to_gtf:
	@echo "Converting GFF to GTF for ${GENOME_NAME}"
	gffread ${GENOME_NAME}.gff -T -o ${GENOME_NAME}.gtf

fix_gtf:
	@echo "Fixing gene_id fields for ${GENOME_NAME}.gtf"
	sed -E 's/transcript_id "gene-([^"]+)";/gene_id "\1"; transcript_id "\1";/' \
		${GENOME_NAME}.gtf > ${GENOME_NAME}.fixed.gtf

# Get metadata for BioProject
get_bioproject:
	@echo "Fetching metadata for bioproject ${PRR}"
	bio search ${PRR} -H --csv > metadata.csv

# Get data for one SRR
get_srr:
	@echo "Fetching SRR data for ${SRR}"
	mkdir -p ${DIR}
	bio fetch ${SRR}

# Download 150000 reads from SRR and get stats
download_reads:
	@echo "Downloading 150000 reads from ${SRR} and getting stats"
	fastq-dump -X 150000 --outdir reads --split-files $(SRR)
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

# Determine feature counts using featureCounts
feature_counts:
	@echo "Calculating feature counts for ${SAMPLE}"
	featureCounts -p \
		-t CDS \
		-g gene_id \
		-a ${GENOME_NAME}.fixed.gtf \
		-o ${BAM_DIR}/${SAMPLE}.feature_counts.txt \
		${BAM}


# Format feature counts into a count matrix using R script
format_counts:
	@echo "Formatting feature counts for ${SAMPLE}"
	micromamba run -n stats Rscript src/r/format_featurecounts.r \
		-c ${BAM_DIR}/${SAMPLE}.feature_counts.txt \
		-o ${BAM_DIR}/${SAMPLE}_count_matrix.csv

# Process the counts.csv using edger
process_counts:
	@echo "Processing count matrix using edgeR"
	micromamba run -n stats Rscript src/r/edger.r -d design.csv -c counts.csv

# Generate PCA plot
generate_pca:
	@echo "Generating PCA plot from count matrix"
	micromamba run -n stats Rscript src/r/plot_pca.r -c edger.csv -d design.csv -o pca.pdf

# Generate heatmap
generate_heatmap:
	@echo "Generating heatmap from count matrix"
	micromamba run -n stats Rscript src/r/plot_heatmap.r -c edger.csv -d design.csv -o heatmap.pdf

# Identify differentially expressed genes
differential_expression:
	@echo "Identifying differentially expressed genes"
	cat edger.csv | cut -f 1 -d ,  | head -10

#Get Ensembl Bacteria FASTA File
get_ensembl_fasta:
	@echo "Fetching FASTA file from Ensembl Bacteria for ${RF}"
	wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/bacteria/release-62/fasta/bacteria_113_collection/staphylococcus_aureus_subsp_aureus_usa300_fpr3757_gca_000013465/dna/Staphylococcus_aureus_subsp_aureus_usa300_fpr3757_gca_000013465.ASM1346v1_.dna.toplevel.fa.gz

# Unzip FASTA file
unzip_ensembl_fasta:
	@echo "Unzipping FASTA file"
	gunzip -c Staphylococcus_aureus_subsp_aureus_usa300_fpr3757_gca_000013465.ASM1346v1_.dna.toplevel.fa.gz > usa300.fna
	@echo "Unzipped to usa300.fna"

# Get GFF3 File from Ensembl Bacteria
get_ensembl_gff:
	@echo "Fetching GFF3 file from Ensembl Bacteria for ${RF}"
	wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/bacteria/release-62/gff3/bacteria_113_collection/staphylococcus_aureus_subsp_aureus_usa300_fpr3757_gca_000013465/Staphylococcus_aureus_subsp_aureus_usa300_fpr3757_gca_000013465.ASM1346v1.62.gff3.gz

# Unzip GFF3 file
unzip_ensembl_gff:
	@echo "Unzipping GFF3 file"
	gunzip -c Staphylococcus_aureus_subsp_aureus_usa300_fpr3757_gca_000013465.ASM1346v1.62.gff3.gz > usa300.gff3
	@echo "Unzipped to usa300.gff3"

# Index the Ensembl reference genome for alignment
index_ensembl_genome:
	@echo "Indexing reference genome"
	bwa index ${RF_ENSEMBL}
	samtools faidx ${RF_ENSEMBL}

# Align the reads to Ensembl genome and convert to BAM
align_ensembl:
	@echo "Aligning reads to Ensembl reference genome and converting to BAM"
	mkdir -p $(dir ${BAM_ENSEMBL})
	bwa mem -t 4 ${RF_ENSEMBL} ${R1} ${R2} | samtools sort > ${BAM_ENSEMBL}
	samtools index ${BAM_ENSEMBL}

# Feature counts using Ensembl GFF3
feature_counts_ensembl:
	@echo "Calculating feature counts using Ensembl GFF3 for ${SAMPLE}"
	mkdir -p $(ENSEMBL_DIR)
	featureCounts -p \
		-t gene \
		-g gene_id \
		-a usa300.gff3 \
		-o $(ENSEMBL_DIR)/${SAMPLE}.feature_counts.txt \
		${BAM_ENSEMBL}

# Process Ensembl feature counts into a count matrix using R script
format_ensembl_counts:
	@echo "Formatting Ensembl feature counts for ${SAMPLE}"
	micromamba run -n stats Rscript src/r/format_featurecounts.r \
		-c $(ENSEMBL_DIR)/${SAMPLE}.feature_counts.txt \
		-o $(ENSEMBL_DIR)/${SAMPLE}_count_matrix.csv

# Determine feature counts using Ensembl data with edgeR
process_ensembl_counts:
	@echo "Processing Ensembl count matrix using edgeR"
	micromamba run -n stats Rscript src/r/edger.r -d design.csv -c counts_ensembl.csv

# Identify differentially expressed genes using Ensembl data
differential_expression_ensembl:
	@echo "Identifying differentially expressed genes using Ensembl data"
	cat edger.csv | cut -f 1 -d ,  | head -10

# Generate PCA plot using Ensembl data
generate_ensembl_pca:
	@echo "Generating PCA plot from Ensembl count matrix"
	micromamba run -n stats Rscript src/r/plot_pca.r -c counts_ensembl.csv -d design.csv -o ensembl_pca.pdf	

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf ${DIR} ${DIR2} bam/*.bedgraph bam/*.bw bam/*.bam bam/*.bai metadata.csv ${GENOME_NAME}.fna ${GENOME_NAME}.gff

