## Assignment for Week 6

# Answers to Questions

# Makefiles

In the Makefile, I had to set the variables shown below. This makes coding easily reproducible because the variable can be changed witout rewriting the entire code.

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
    BAM=alignments/${SRR}.bam

# Get reference genome in FASTA and GFF format

The code below was used to get the reference genome for Staphylococcus aureus. This is needed for future viewing and annotation in IGV. 

    get_genome:
	bio fetch ${RF} -format fasta > ${RF}.fna
	bio fetch ${RF} -format gff > ${RF}.gff


# Retrieving data from Bioproject ID (fetch all SRRs)

For this bioproject, there are numerous SRRs because there are numerous sequencing runs. This is an RNA-seq dataset, so there are numerous replicates and controls. 


    get_bioproject:
	mkdir -p ${DIR}
	for srr in $$(esearch -db sra -query ${PRR} | efetch -format runinfo | cut -d ',' -f 1 | grep SRR); do \
		echo "Fetching $$srr"; \
		bio fetch $$srr; \
	done

# Retrieving data from one SRR

The code below can be used to retrieve the data from one SRR. The variable could be changed to allow for retrieval from other SRRs. 

    get_srr:
	mkdir -p ${DIR}
	bio fetch ${SRR}

# Download first 1000 reads from SRR and get stats

This code downloads the first 1000 reads from the SRR and gets the stats of the reads. If it’s paired-end sequencing, the code will split into two files (_1.fastq and _2.fastq). Seqkit stats will summarize FASTQ file statistics. 


    download_reads:
	fastq-dump -X 1000 -F --outdir reads --split-files ${SRR}
	seqkit stats reads/${SRR}_1.fastq reads/${SRR}_2.fastq > reads/${SRR}_stats.txt
	cat reads/${SRR}_stats.txt

# Run FastQC on the reads 

FastQC is a quality control tool for FASTQ sequencing reads and produces a report about data quality. The HTML file can be opened in the browser to see the results. This code makes a directory to store the FastQC data and then also runs FastQC.


    fastqc:
	mkdir -p ${DIR2}
	fastqc -o ${DIR2} reads/${SRR}_1.fastq reads/${SRR}_2.fastq

# Index the reference genome for alignment

This code uses BWA to build an index of the reference genome. This index will be used to help align the RNA-seq reads to the genome. 

    index_genome:
	bwa index ${RF}.fna
	samtools faidx ${RF}.fna

# Align the reads and convert to BAM

This code creates an output directory for the BAM files. Bwa mem is the aligner that will align the reads to the genome. This creates a bam index file (bai).

    align:
	mkdir -p $(dir ${BAM})
	bwa mem -t 4 ${REF} ${R1} ${R2} | samtools sort  > ${BAM}
	samtools index ${BAM}

# Generate alignment statistics

This code checks the quality of the alignment. It can check how many total reads there are, how many reads are mapped, as well as other information. 

    alignment_stats:
	samtools flagstat ${BAM} > ${BAM}_stats.txt
	cat ${BAM}_stats.txt

# Clean up generated files

This is not a necessary step, but it will help by removing files if the code needs rerun. This was helpful when I was troubleshooting, as I did not have duplicate files. 

    clean:
	rm -rf ${REF} ${R1} ${R2} ${BAM} ${BAM}.bai

# Run everything and shortcut to run everything

This code defines "all" and then lets you run the code by simply typing "make run". 

    all: 
    get_genome get_srr download_reads fastqc index_genome align alignment_stats
    
    run: 
    all

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

