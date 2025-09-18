# Assignment for Week 4

## Answers to Questions

In this paper the author's are using Staphyloccoccus aureus USA300. The accession number for the reference genome is NC_007793.1.

## Download the data

    bio fetch NC_007793.1 -format fasta > NC_007793.1.fna
    bio fetch NC_007793.1 -format gff > NC_007793.1.gff

## Genome size

The genome is 2872769 base pairs.

    bio fetch NC_007793.1 -format fasta | awk '/^>/ {next} {sum += length($0)} END {print "Genome size (bp):", sum}'

## Feature types


    grep -v '^#' NC_007793.1.gff | awk -F'\t' 'NF==9 {print $3}' | sort | uniq -c | sort -nr
 
 Output

     2713 CDS
     2689 gene
     78 pseudogene
     72 exon
     52 tRNA
     15 rRNA
     13 riboswitch
      3 sequence_feature
      3 binding_site
      1 tmRNA
      1 region
      1 ncRNA
      1 SRP_RNA
      1 RNase_P_RNA

## Longest gene

The longest gene is SAUSA300_RS072 and it is 31,266 bp. I could not find any additional information on this gene, so perhaps it is a gene or region of unknown function. 

    grep -v '^#' NC_007793.1.gff | awk -F'\t' 'NF==9 && $3=="gene" {print $1, $4, $5, $9}' > genes.tmp
    awk '{print $0, $3-$2+1}' genes.tmp | sort -k5,5nr | head -n 1

## Another gene

There is a gene named sbnH. This gene codes for a decarboxylase enzyme involved in the biosynthesis of staphyloferrin B. Staphyloferrin B is a siderophore which binds and transports iron. Iron is important for the virulence of S. aureus. 

## Viewing in IGV 

The genome appears to be predominantly closely packed coding sequences, but many of them are not annotated or labelled as "anonymous." I would say about 70% appears to be coding sequences. 



    mv NC_007793.1.fna NC_007793.1.fa
    samtools faidx NC_007793.1.fa

## Other genomic builds

Since methicillin-resistant Staphylococcus aureus (MRSA) is such a global health burden, perhaps another genome of a clinically relevant stain could be examined as well. The transcriptomic profiles of these isolates could be examined as well to determine if treatment with sodium propionate was equally effective against all strains. This could provide insights into whether sodium propionate could be used broadly as a bacteriocidal agent against MRSA infections. Other accession numbers for Staphyloccus aureus GCF_002895385.1 (MRSA 107) and GCF_030252735.1 (CC239-MRSA-III(var.)). 