#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  fastq1:
    type: File
  fastq2:
    type: File
  threads:
    type: int
    default: 1
  outprefix:
    type: string
    default: out  # output prefix for trimmomatic log/stats
  stats_out:
    type: string
    default: read-stats.txt
  stats_out_raw:
    type: string
    default: read-stats-raw.txt

steps:

  fastqc_raw:
    run: ../tools/fastqc-PE.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      threads: threads
    out: [result1, result2]


  seqkit_stats_raw:
    run: ../tools/seqkit-stats-PE.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      threads: threads
      stats_out: stats_out_raw
    out: [result]

  get_adapter_fasta:
    run: ../tools/trimmomatic-getAdapterFasta.cwl
    in: {}
    out: [adapter_fasta]

  trimmomatic:
    run: ../tools/trimmomatic.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      threads: threads
      outprefix: outprefix
      adapter: get_adapter_fasta/adapter_fasta
    out: [pe1, pe2, summary]


  fastqc:
    run: ../tools/fastqc-PE.cwl
    in:
      fastq1: trimmomatic/pe1
      fastq2: trimmomatic/pe2
      threads: threads
    out: [result1, result2]

  seqkit_stats:
    run: ../tools/seqkit-stats-PE.cwl
    in:
      fastq1: trimmomatic/pe1
      fastq2: trimmomatic/pe2
      threads: threads
      stats_out: stats_out
    out: [result]


outputs:
    fastqc_raw_result1:
      type: File
      outputSource: fastqc_raw/result1 
    fastqc_raw_result2:
      type: File
      outputSource: fastqc_raw/result2 
    preprocessed_fastq1:
      type: File
      outputSource: trimmomatic/pe1
    preprocessed_fastq2:
      type: File
      outputSource: trimmomatic/pe2
    # trimmomatic_log:
    #   type: File
    #   outputSource: trimmomatic/log
    trimmomatic_summary:
      type: File
      outputSource: trimmomatic/summary
    fastqc_result1:
      type: File
      outputSource: fastqc/result1
    fastqc_result2:
      type: File
      outputSource: fastqc/result2
    read_stats:
      type: File
      outputSource: seqkit_stats/result
    read_stats_raw:
      type: File
      outputSource: seqkit_stats_raw/result

