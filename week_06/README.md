## Assignment for Week 6

# How to run the Makefile

This pipeline allows you to: obtain a reference genome, download sequencing reads from the SRA, create a quality report, index the genome, and align the reads.

These tasks are set as "targets" within the Makefile, allowing them to be executed individually or run together.

# Get Genome

Run the following code to use the accession number to get the reference genome in FASTA and GFF format

    make get_genome

# Get Bioproject

Run the following code to get the SRR numbers associated with the bioproject

    make get_bioproject

# Retrieving data from one SRR

Run the following code to retrieve the data from one SRR and create a directory for the output

    make get_srr


# Download first 1000 reads from SRR and get stats

Run the following code to download the first 1000 reads from the SRR and gets the stats of the reads. If it’s paired-end sequencing, the code will split into two files (_1.fastq and _2.fastq). Seqkit stats will summarize FASTQ file statistics. 

    make download_reads

# Run FastQC on the reads 

Use the following code to run FastQC. FastQC is a quality control tool for FASTQ sequencing reads and produces a report about data quality. The HTML file can be opened in the browser to see the results. This code makes a directory to store the FastQC data and then also runs FastQC.

    make fastqc
	

# Index the reference genome for alignment

This code uses BWA to build an index of the reference genome. This index will be used to help align the RNA-seq reads to the genome. 

   make index_genome

# Align the reads and convert to BAM

This code creates an output directory for the BAM files. Bwa mem is the aligner that will align the reads to the genome. This creates a bam index file (bai).

    make align


# Generate alignment statistics

This code checks the quality of the alignment. It can check how many total reads there are, how many reads are mapped, as well as other information. 

   make alignment_stats


# Clean up generated files

This is not a necessary step, but it will help by removing files if the code needs rerun. This was helpful when I was troubleshooting, as I did not have duplicate files. 

    make clean

# Run everything 

    make run

# Customization

The Makefile can be customized for your own uses. The genome as well as other variables can be changed by editing the top of the Makefile. For example, this reference genome could be changed to your organism of interest.

     RF=NC_007793.1

# Alignment Statistics for BAM file

I included the alignment statistics below. There are 2001 reads in the BAM file. The +0 means that none failed QC filters. Out of 2001 reads, 1997 mapped to the reference genome, which is a 99.8% mapping rate. The expected coverage from this is very low, as I only downloaded a subset of reads (~2000 reads). 2000 reads multiplied by the read length (101 bp) and divided by the genome size (2.8 Mbp) is an expected coveraged of 0.072x. I used the code shown below to calculate the average coverage, and I got 0.0699893x, which is approximately ~0.07x. 

    $ samtools depth -a alignments/SRR21835896.bam | awk '{sum+=$3} END {print sum/NR}'

Based on the IGV file, coverage varies widely across the genome, but this makes sense. I only downloaded a subset of reads and this is also an RNA-seq experiment. This means that highly expressed genes will have more reads than other genes. I believe expected coverage makes sense, as there was only one cluster of genes that were expressed. I would see better coverage if I downloaded all of the reads from all of the SRRs. 


    Output
    2001 + 0 in total (QC-passed reads + QC-failed reads)
    2000 + 0 primary
    0 + 0 secondary
    1 + 0 supplementary
    0 + 0 duplicates
    0 + 0 primary duplicates
    1997 + 0 mapped (99.80% : N/A)
    1996 + 0 primary mapped (99.80% : N/A)
    2000 + 0 paired in sequencing
    1000 + 0 read1
    1000 + 0 read2
    1984 + 0 properly paired (99.20% : N/A)
    1996 + 0 with itself and mate mapped
    0 + 0 singletons (0.00% : N/A)
    0 + 0 with mate mapped to a different chr
    0 + 0 with mate mapped to a different chr (mapQ>=5)

