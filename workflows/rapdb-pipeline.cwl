#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  reference:
    type: File
    doc: FASTA file for reference genome
  ref_gtf:
    type: File
    doc: Reference GTF file for snpEff
  ref_protein:
    type: File
    doc: Reference protein FASTA for snpEff
  fastq1:
    type: File
  fastq2:
    type: File
  outprefix:
    type: string
  threads:
    type: int

steps:
  prepare_referemce:
    run: prepare_reference.cwl 
    in:
      reference: reference
    out: [fasta_with_index]

  fastq2bam:
    run: fastq2bam.cwl 
    in:
      reference: prepare_referemce/fasta_with_index
      fastq1: fastq1
      fastq2: fastq2
      outprefix: outprefix
      threads: threads
    out: [rmdup_bam_with_index, rmdup_metrics]

  bam2vcf:
    run: bam2vcf.cwl 
    in:
      bam: fastq2bam/rmdup_bam_with_index
      reference: prepare_referemce/fasta_with_index
      fastq2: fastq2
      outprefix: outprefix
      threads: threads
    out: [gvcf]

  snpeff:
    run: snpeff_all.cwl 
    in:
      genome: prepare_referemce/fasta_with_index
      gtf: ref_gtf
      protein: ref_protein
      vcf: bam2vcf/gvcf
      outprefix: outprefix
    out: [snpeff_vcf_with_tbi, snpeff_genes, snpeff_summary]

outputs:
  bam_with_index:
    type: File
    outputSource: fastq2bam/rmdup_bam_with_index
  rmdup_metrics:
    type: File
    outputSource: fastq2bam/rmdup_metrics
  vcf_with_tbi:
    type: File
    outputSource: bam2vcf/gvcf
  snpeff_vcf:
    type: File
    outputSource: snpeff/snpeff_vcf_with_tbi
  snpeff_genes:
    type: File
    outputSource: snpeff/snpeff_genes
  snpeff_summary:
    type: File
    outputSource: snpeff/snpeff_summary

