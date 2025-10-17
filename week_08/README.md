# Assignment for Week 8

## How to run the Makefile

This Makefile allows you to download a reference genome, rename that genome to a user friendly name, download the metadata associated with a Bioproject, create a design.csv to correlate SRR numbers with sample names, download the reads, perform fastqc, index the genome, align the reads, as well as create BAM and BigWig files. The reference genome for this project is from Staphylococcus aureus USA300.

## Get Genome

Run the following code to get the reference genome in FASTA and GFF format. The genome is renamed "Staphaureus" to make it more user friendly.

    make get_genome

## Get Bioproject

Run the following code to download all of the metadata (SRR numbers) for the Bioproject and save that data as metadata.csv.

    make get_bioproject

## Previewing sample names

Run the following code to preview the sample names before making the design.csv file. I used the metadata.csv file to create the design.csv file which I also uploaded to the GitHub repository for easier viewing. The design.csv file contains the SRR numbers and their corresponding sample names.

    make get_sample_names

## Create design.csv and connect SRR numbers to Sample names

After creating the design.csv, run the following code to connect the SRR numbers to the sample names.

    make get_design

## Get data from SRRs using parallel

Run the following code to get the data from each SRR using parallel. Parallel allows us to run multiple jobs simultaneously, which speeds up the process of retrieving data.

    make get_srrs

## Download 10000 reads from each SRR and get stats

Run the following code to download 10000 reads from each SRR and get the statistics on those reads. This code also uses parallel.

    make download_reads

## Run FastQC on the reads 

Use the following code to run FastQC. FastQC is a quality control tool for FASTQ sequencing reads and produces a report about data quality. The HTML file can be opened in the browser to see the results. This code makes a directory to store the FastQC data and then also runs FastQC.

    make fastqc

## Index the reference genome for alignment

This code uses BWA to build an index of the reference genome. This index will be used to help align the RNA-seq reads to the genome.

    make index_genome

## Align the reads and convert to BAM

This code creates an output directory for the BAM files. Bwa mem is the aligner that will align the reads to the genome. This creates a bam index file (bai). This code also uses parallel so it can align reads from multiple SRRs simultaneously.

    make align

## Generate alignment statistics

Run this code to check the quality of the alignments. This code also uses parallel. 

    make alignment_stats

## Generate BedGraph coverage files

Run this code to generate a BedGraph coverage file from the BAM files while using parallel.

    make bam_to_bedgraph

## Convert BedGraph to BigWig

Run this code to convert the temporary BedGraph file to BigWig wile using parallel.

    bedgraph_to_bigwig:

## Clean up generated files

This is not a necessary step, but it will help by removing files if the code needs rerun or for troubleshooting. 

    make clean

## Run everything

To run the entire Makefile, use the code below.

    make run

## Troubleshooting

While trying to create/run this Makefile, I ran into issues where the code would "hang" in the terminal. I found a way to fix that by adding this section to my Makefile. These commands below separate out what needs run per sample, and stopped the code from hanging in the terminal. When you use "make run" per_sample and per_sample_all are defined, so the code runs entirely. 

    # Run per-sample commands
    per_sample:
	@echo "Processing $(SRR) ($(SAMPLE))"
	# Example: download reads for this sample
	fastq-dump -X 10000 -F --outdir reads --split-files $(SRR)
	seqkit stats reads/$(SRR)_1.fastq reads/$(SRR)_2.fastq > reads/$(SRR)_$(SAMPLE)_stats.txt

    # Run all samples in parallel (calls per_sample for each row)
    per_sample_all:
	@echo "Running per-sample workflows for all SRRs in design.csv"
	cat design.csv | parallel -j 1 --colsep , --header : \
		make per_sample SRR={SRR_numbers} SAMPLE={sample_names}