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
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - $(self.nameroot).dict
      # - ^.dict
  # ref_gtf:
  #   type: File
  #   doc: Reference GTF file for snpEff
  # ref_protein:
  #   type: File
  #   doc: Reference protein FASTA for snpEff
  fastq1:
    type: File
    doc: FASTQ file for the forward read
  fastq2:
    type: File
    doc: FASTQ file for the reverse read
  outprefix:
    type: string
    default: out
    doc: Prefix for output files
  threads:
    type: int
    default: 1
    doc: Number of threads for parallel processing
  # filter-expression:
  #   type: string
  #   doc: VCF filter condition for GATK-VariantFiltration
  #   default: "QD < 5.0 || FS > 50.0 || SOR > 3.0 || MQ < 50.0 || MQRankSum < -2.5 || ReadPosRankSum < -1.0 || ReadPosRankSum > 3.5"

#  dbname:
#    type: string
#    default: RAP_MSU_on_IRGSP-1.0

steps:
  read_preprocessing:
    run: /home/yanakamu/rice_reseq/pipeline/workflows/read_preprocessing.cwl
    in: 
      fastq1: fastq1
      fastq2: fastq2
      threads: threads
      outprefix: outprefix
      stats_out: 
        source: outprefix
        valueFrom: ${ return self + "_read-stats" + ".tsv"}
      stats_out_raw: 
        source: outprefix
        valueFrom: ${ return self + "_read-stats-raw" + ".tsv"}
    out: [preprocessed_fastq1, preprocessed_fastq2, trimmomatic_summary, fastqc_result1, fastqc_result2, read_stats, read_stats_raw, fastqc_raw_result1, fastqc_raw_result2]

  # prepare_reference:
  #   run: /home/yanakamu/rice_reseq/pipeline/workflows/prepare_reference.cwl 
  #   in:
  #     reference: reference
  #   out: [fasta_with_index]

  fastq2bam:
    run: /home/yanakamu/rice_reseq/pipeline/workflows/fastq2bam.cwl 
    in:
      reference: reference
      fastq1: read_preprocessing/preprocessed_fastq1
      fastq2: read_preprocessing/preprocessed_fastq2
      outprefix: outprefix
      threads: threads
    out: [rmdup_bam_with_index, rmdup_metrics, stats, unmapped_fastq1, unmapped_fastq2]

#   bam2vcf:
#     run: bam2vcf.cwl 
#     in:
#       bam: fastq2bam/rmdup_bam_with_index
#       reference: prepare_reference/fasta_with_index
#       outprefix: outprefix
#       threads: threads
#       filter-expression: filter-expression
#     out: [hc_gvcf, varonly_vcf]

#   snpeff:
#     run: snpeff_all.cwl 
#     in:
#       genome: prepare_reference/fasta_with_index
#       gtf: ref_gtf
#       protein: ref_protein
#       vcf: bam2vcf/varonly_vcf
#       outprefix: outprefix
# #      dbname: dbname
#     out: [snpeff_vcf_with_tbi, snpeff_genes, snpeff_summary]

#   bam2tasuke:
#     run: ../workflows/bam2tasuke.cwl 
#     in:
#       bam: fastq2bam/rmdup_bam_with_index
#       outprefix: outprefix
#     out: [tasuke_depth, avg_depth]

outputs:
  read_stats_raw:
    type: File
    outputSource: read_preprocessing/read_stats_raw
  fastqc_raw_result1:
    type: File
    outputSource: read_preprocessing/fastqc_raw_result1
  fastqc_raw_result2:
    type: File
    outputSource: read_preprocessing/fastqc_raw_result2
  fastqc_result1:
    type: File
    outputSource: read_preprocessing/fastqc_result1
  fastqc_result2:
    type: File
    outputSource: read_preprocessing/fastqc_result2
  trimmomatic_summary:
    type: File
    outputSource: read_preprocessing/trimmomatic_summary
  read_stats:
    type: File
    outputSource: read_preprocessing/read_stats
  bam_with_index:
    type: File
    outputSource: fastq2bam/rmdup_bam_with_index
  rmdup_metrics:
    type: File
    outputSource: fastq2bam/rmdup_metrics
  bam_stats:
    type: File
    outputSource: fastq2bam/stats
  unmapped_fastq1:
    type: File
    outputSource: fastq2bam/unmapped_fastq1
  unmapped_fastq2:
    type: File
    outputSource: fastq2bam/unmapped_fastq2
  # hc_gvcf_with_tbi:
  #   type: File
  #   outputSource: bam2vcf/hc_gvcf
  # vcf_with_tbi:
  #   type: File
  #   outputSource: bam2vcf/varonly_vcf
  # snpeff_vcf:
  #   type: File
  #   outputSource: snpeff/snpeff_vcf_with_tbi
  # snpeff_genes:
  #   type: File
  #   outputSource: snpeff/snpeff_genes
  # snpeff_summary:
  #   type: File
  #   outputSource: snpeff/snpeff_summary
  # tasuke_depth:
  #   type: File
  #   outputSource: bam2tasuke/tasuke_depth
  # avg_depth:
  #   type: File
  #   outputSource: bam2tasuke/avg_depth

