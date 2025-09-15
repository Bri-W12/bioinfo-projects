# Assignment for Week 2

## Answers to Questions


I chose the organism Felis catus which is the domestic cat. Felis catus is the only domesticated member of the Felidae family. Based on genetics, cats were domesticated around 7500 BC.

## Sequence regions and expectations

    wget https://ftp.ensembl.org/pub/current_gff3/felis_catus/Felis_catus.F.catus_Fca126_mat1.0.115.gff3.gz
    ls Felis_catus.F.catus_Fca126_mat1.0.115.gff3.gz
    gunzip Felis_catus.F.catus_Fca126_mat1.0.115.gff3.gz
    cat Felis_catus.F.catus_Fca126_mat1.0.115.gff3 | more

Answer: The output for this code is very long. Cats' chromosomes are named A-F plus a sex chromosome (X or Y). Based on the output, I can identify 18 autosomal chromosomes plus 1 sex chromosome which is X. This makes sense as cats have 18 autosomal pairs plus sex chromosomes. The files contains 239367248 sequence regions.

## Total Number of Features

     cat Felis_catus.F.catus_Fca126_mat1.0.115.gff3  | grep -v '#' > catus.gff3
     ls
     wc -l < catus.gff3


Answer: The output is 2301949, meaning that there are 2301949 total features.

## Genes

     cat catus.gff3 | cut -f 3 | sort | uniq -c | sort -rn | head

Answer: There are  19209 genes listed.

## Feature Types

    cat catus.gff3 | cut -f 3 | sort | uniq -c | sort -rn | head

Answer: One of the features that showed up was snRNA. I have heard of snRNAs before, but I am not overly familiar with them. snRNAs are small nuclear RNAs that are located in the nucleus of cells and have roles in RNA processing. 

## Top 10 Most Annotated Feature Types

    cat catus.gff3 | cut -f 3 | sort | uniq -c | sort -rn | head

Output:
   
    912206 exon
    717412 CDS
    336181 biological_region
    116471 five_prime_UTR
    90775 three_prime_UTR
    62351 mRNA
    29008 lnc_RNA
    19209 gene
    14844 ncRNA_gene
    1576 snRNA

Answer: The top ten most annotated feature types are exons, CDS, biological regions, five prime UTRs, three prime UTRs, mRNA, lnc RNA, genes, ncRNA genes, and snRNAs.

## Analyzing the GFF file

Answer: After doing some research, I do believe that this is a complete and well-annotated GFF file. Cats have approximately 20,000 genes, so 19209 annotated genes is very close to that number. I believe that the number of exons also makes sense, as eukaryotes tend to have multiple exons per gene.

## Other Insights 

I thought it was interesting that the number of annotated genes in cats (~19k) is similar to the number of protein-coding genes in humans and dogs. 

    

    