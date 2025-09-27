<<<<<<< HEAD
# bioinfo-projects
Assignments for bioinfo BMMB852
=======
# Assignment for Week 5

## Answers to Questions

## 10X Coverage

Since the Staphylococcus aureus genome is 2872769 base pairs, I rounded that up to ~2.9 mb. I used the codes below to determine the average read length, and determined that I needed approximately 290,000 reads.

    fastq-dump -X 290000 -F --outdir reads --split-files $SRR
    seqkit stats reads/${SRR}_1.fastq reads/${SRR}_2.fastq > reads/${SRR}_stats.txt
    cat reads/${SRR}_stats.txt

## Quality Assessment 

This sequencing data was obtained using Illumina NovaSeq 6000. Based on the FastQC report, none of the sequences were flagged as poor quality, the sequence length was 101, and the %GC was 33. The %GC content appears to be slightly higher than the theoretical distribution. 

## Compare sequencing platforms

I found a sequencing dataset obtained through Oxford Nanopore (MinION). This sequencing dataset has the following ID DRR660590. Based on the FastQC report, none of the sequences were flagged as poor quality. The sequencing length did vary from 152-46675. The %GC is 32. For this dataset, the sequencing quality seems to be lower overall. I believe this makes sense, as Oxford Nanopore sequencing tends to be able to handle longer reads than Illumina. Additionally, I believe the accuracy of Nanopore sequencing is slightly lower as well, depending on the basecalling software.





>>>>>>> master
