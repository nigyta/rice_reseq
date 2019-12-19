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
    default: 1
  dbname:
    type: string
    default: RAP_MSU_on_IRGSP-1.0

steps:
  read_preprocessing:
    run: read_preprocessing.cwl
    in: 
      fastq1: fastq1
      fastq2: fastq2
      threads: threads
      stats_out: 
        source: outprefix
        valueFrom: ${ return "read-stats_" + self + ".tsv"}
    out: [preprocessed_fastq1, preprocessed_fastq2, fastqc_result1, fastqc_result2, read_stats]

  prepare_reference:
    run: prepare_reference.cwl 
    in:
      reference: reference
    out: [fasta_with_index]

  fastq2bam:
    run: fastq2bam.cwl 
    in:
      reference: prepare_reference/fasta_with_index
      fastq1: read_preprocessing/preprocessed_fastq1
      fastq2: read_preprocessing/preprocessed_fastq2
      outprefix: outprefix
      threads: threads
    out: [rmdup_bam_with_index, rmdup_metrics]

  bam2vcf:
    run: bam2vcf.cwl 
    in:
      bam: fastq2bam/rmdup_bam_with_index
      reference: prepare_reference/fasta_with_index
      outprefix: outprefix
      threads: threads
    out: [hc_gvcf, varonly_vcf]

  snpeff:
    run: snpeff_all.cwl 
    in:
      genome: prepare_reference/fasta_with_index
      gtf: ref_gtf
      protein: ref_protein
      vcf: bam2vcf/varonly_vcf
      outprefix: outprefix
      dbname: dbname
    out: [snpeff_vcf_with_tbi, snpeff_genes, snpeff_summary]

#  tasuke_conv:
#    run: ../tools/tasuke_bamtodepth/tasuke_bamtodepth.cwl 
#    in:
#      input_bam: fastq2bam/rmdup_bam_with_index
#      output_file:
#        source: outprefix
#        valueFrom: ${ return "alignment_depth_" + self + ".tsv"}
#
#    out: [tasuke_depth]

outputs:
  read_stats:
    type: File
    outputSource: read_preprocessing/read_stats
  fastqc_result1:
    type: File
    outputSource: read_preprocessing/fastqc_result1
  fastqc_result2:
    type: File
    outputSource: read_preprocessing/fastqc_result2
  bam_with_index:
    type: File
    outputSource: fastq2bam/rmdup_bam_with_index
  rmdup_metrics:
    type: File
    outputSource: fastq2bam/rmdup_metrics
  hc_gvcf_with_tbi:
    type: File
    outputSource: bam2vcf/hc_gvcf
  vcf_with_tbi:
    type: File
    outputSource: bam2vcf/varonly_vcf
  snpeff_vcf:
    type: File
    outputSource: snpeff/snpeff_vcf_with_tbi
  snpeff_genes:
    type: File
    outputSource: snpeff/snpeff_genes
  snpeff_summary:
    type: File
    outputSource: snpeff/snpeff_summary
#  tasuke_depth:
#    type: File
#    outputSource: tasuke_conv/tasuke_depth

