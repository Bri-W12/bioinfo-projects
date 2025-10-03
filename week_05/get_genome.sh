# Make scripts behave a little better
set -uexo pipefail

# Accesssion number for reference genome
RF=NC_007793.1

# Bioproject ID
PRR=PRJNA887926

# SRR Number
SRR=SRR21835896


-----------------------------

# Download reference genome in fasta and gff format
bio fetch $RF -format fasta > ${RF}.fna
bio fetch $RF -format gff > ${RF}.gff

# Determine genome size
bio fetch $RF -format fasta | awk '/^>/ {next} {sum += length($0)} END {print "Genome size (bp):", sum}'

# Determine feature types
grep -v '^#' ${RF}.gff | awk -F'\t' 'NF==9 {print $3}' | sort | uniq -c | sort -nr

# Determine the longest gene
awk -F'\t' '$3 == "gene" {len = $5 - $4 + 1; print len, $9}' ${RF}.gff | sort -nr | head -n 1

