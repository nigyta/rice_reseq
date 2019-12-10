#!/bin/bash

mkdir ref
cd ref
curl -LO https://rapdb.dna.affrc.go.jp/download/archive/genome-wide_variations/IRGSP-1.0_genome_M_C_unanchored.fa.gz
curl -LO https://rapdb.dna.affrc.go.jp/download/archive/genome-wide_variations/RAP-DB_MSU_concatenated_for_snpEff.gtf.gz
curl -LO https://rapdb.dna.affrc.go.jp/download/archive/genome-wide_variations/RAP-DB_MSU_concatenated_protein.fa.gz
gunzip *.gz