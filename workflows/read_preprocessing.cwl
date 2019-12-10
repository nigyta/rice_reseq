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
  stats_out:
    type: string
    default: read-stats.txt

steps:
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
      adapter: get_adapter_fasta/adapter_fasta
    out: [pe1, pe2]


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
    preprocessed_fastq1:
      type: File
      outputSource: trimmomatic/pe1
    preprocessed_fastq2:
      type: File
      outputSource: trimmomatic/pe2
    fastqc_result1:
      type: File
      outputSource: fastqc/result1
    fastqc_result2:
      type: File
      outputSource: fastqc/result2
    read_stats:
      type: File
      outputSource: seqkit_stats/result

