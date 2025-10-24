# Assignment for Week 9

## About the Makefile and README

This is the revised code from the assignment from Week 8. For additional information on the Makefile, please see README files in Week 7 and Week 8. 

## Running Samples in Parallel (Dry run)

Below is the code used to do a dry-run of parallel.

     cat design.csv | parallel --dry-run --colsep , --header : "make download_reads SRR={SRR_numbers} SAMPLE={sample_names}"

## Running Samples in Parallel (Download reads)

Below is the code used to use parallel to download reads from all SRRs in parallel

    cat design.csv | parallel --colsep , --header : "make download_reads SRR={SRR_numbers} SAMPLE={sample_names}"

## Adding a -j parameter 

A -j parameter can be added to change how many jobs run at a time. A -j of 1 means that one job runs at a time. To process more samples simultaneously, adjust the -j parameter to a higher number.

    cat design.csv | parallel -j 1 --colsep , --header : "make download_reads SRR={SRR_numbers} SAMPLE={sample_names}"

