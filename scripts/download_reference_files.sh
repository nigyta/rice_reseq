#!/bin/bash

mkdir reference
cd reference
echo Downloading reference files from RAP-DB...
curl -LO https://rapdb.dna.affrc.go.jp/download/archive/genome-wide_variations/IRGSP-1.0_genome_M_C_unanchored.fa.gz
curl -LO https://rapdb.dna.affrc.go.jp/download/archive/genome-wide_variations/RAP-DB_MSU_concatenated_for_snpEff.gtf.gz
curl -LO https://rapdb.dna.affrc.go.jp/download/archive/genome-wide_variations/RAP-DB_MSU_concatenated_protein.fa.gz
echo Done.
echo Uncompressing files...
gunzip *.gz
echo Done.