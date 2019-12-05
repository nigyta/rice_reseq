#!/bin/bash

## input
ORG_GENOME_FASTA=$1
ORG_ANNOT_GTF=$2
ORG_ANNOT_PROTEIN_FASTA=$3

## setting
SNPEFF_DB_BASENAME=$4  # default: RAP_MSU_on_IRGSP-1.0
BUILD_DIR=$5  # default: snpeff_db

## creating working directory
mkdir -p $BUILD_DIR/data
mkdir -p $BUILD_DIR/data/genomes
mkdir -p $BUILD_DIR/data/${SNPEFF_DB_BASENAME}/

## config file
SNPEFF_RELPATH=`which snpEff`; SNPEFF_ABSPATH=`readlink -f ${SNPEFF_RELPATH}`
SNPEFF_DIR=`dirname ${SNPEFF_ABSPATH}`
cp /usr/local/share/snpeff-4.3.1t-3/snpEff.config $BUILD_DIR/snpEff.config
echo "${SNPEFF_DB_BASENAME}.genome : Oryza sativa Nipponbare IRGSP-1.0" >> $BUILD_DIR/snpEff.config

## prepare annotation data 
ln -s $ORG_GENOME_FASTA $BUILD_DIR/data/genomes/${SNPEFF_DB_BASENAME}.fa
ln -s $ORG_ANNOT_GTF $BUILD_DIR/data/${SNPEFF_DB_BASENAME}/genes.gtf
ln -s $ORG_ANNOT_PROTEIN_FASTA $BUILD_DIR/data/${SNPEFF_DB_BASENAME}/protein.fa


snpEff build -gtf22 -v -c $BUILD_DIR/snpEff.config $SNPEFF_DB_BASENAME 

rm $BUILD_DIR/data/genomes/${SNPEFF_DB_BASENAME}.fa
rm $BUILD_DIR/data/${SNPEFF_DB_BASENAME}/genes.gtf
rm $BUILD_DIR/data/${SNPEFF_DB_BASENAME}/protein.fa
