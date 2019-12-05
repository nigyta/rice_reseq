#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
    genome:
      type: File
    gtf:
      type: File
    protein:
      type: File
    vcf:
      type: File
    dbname:
      type: string
      default: RAP_MSU_on_IRGSP-1.0
    dbdir:
      type: string
      default: snpeff_db
    outprefix:
      type: string

steps:
  snpeff_build:
    run: ../tools/snpeff-build.cwl
    in:
      genome: genome
      gtf: gtf
      protein: protein
      dbname: dbname
      dbdir: dbdir
    out: [dbdir]

  snpeff_annotate:
    run: ../tools/snpeff-annotate.cwl
    in:
      vcf: vcf
      dbdir: snpeff_build/dbdir
      dbname: dbname
      out_vcf: 
        source: outprefix
        valueFrom: variants_$(self).snpEff.vcf
      outprefix: outprefix

    out: [vcf, genes, summary]

  bgzip_vcf:
    run: ../tools/bgzip-vcf.cwl
    in:
      vcf: snpeff_annotate/vcf
    out: [bgzipped_vcf]

  tabix_vcf:
    run: ../tools/tabix-vcf.cwl
    in:
      vcf: bgzip_vcf/bgzipped_vcf
    out: [tbi]

  bind_vcf_index:
    run: ../tools/util-bindVcfIndex.cwl
    in:
      vcf: bgzip_vcf/bgzipped_vcf
      tbi: tabix_vcf/tbi
    out: [vcfgz_with_tbi]

outputs:
    snpeff_vcf_with_tbi:
      type: File
      outputSource: bind_vcf_index/vcfgz_with_tbi
    snpeff_genes:
      type: File
      outputSource: snpeff_annotate/genes
    snpeff_summary:
      type: File
      outputSource: snpeff_annotate/summary

