#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

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
      - ^.dict
  fastq1:
    type: File
  fastq2:
    type: File
  outprefix:
    type: string
    doc: Any string that can distinguish sample.
  threads:
    type: int

steps:
  bwa_mem:
    run: ../tools/bwa-mem.cwl
    in:
      reference: reference
      fastq1: fastq1
      fastq2: fastq2
      outprefix: outprefix
      threads: threads
    out: [sam, log]

  sam2bam:
    run: ../tools/samtools-sam2bam.cwl
    in:
      sam: bwa_mem/sam
      threads: threads
    out: [bam]

  sort_bam:
    run: ../tools/samtools-sort.cwl
    in:
      bam: sam2bam/bam
      threads: threads
    out: [sorted_bam]

  picard_fastq2sam:
    run: ../tools/picard-FastqToSam.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      out_unmapped_bam:
        source: outprefix
        valueFrom: ${ return self + ".uBAM.bam"}
      sample_id: outprefix
    out: [bam]

  picard_merge:
    run: ../tools/picard-MergeBamAlignment.cwl
    in:
      aligned: sort_bam/sorted_bam
      unmapped: picard_fastq2sam/bam
      reference: reference
      out_merged_bam:
        source: outprefix
        valueFrom: ${ return self + ".merge.bam"}
    out: [bam]

  picard_rmdup:
    run: ../tools/picard-MarkDuplicates.cwl
    in:
      input: picard_merge/bam
      out_rmdup_bam: 
        source: outprefix
        valueFrom: ${ return self + ".rmdup.bam"}
      out_metrics_file:
        source: outprefix
        valueFrom: ${ return self + ".rmdup.metrics"}
    out: [bam, metrics]

  bam_indexing:
    run: ../tools/samtools-index.cwl
    in:
      bam: picard_rmdup/bam
      threads: threads
    out: [bai]

  bind_bam_index:
    run: ../tools/util-bindBamIndex.cwl
    in:
      bam: picard_rmdup/bam
      bai: bam_indexing/bai
    out: [bam_with_index]


outputs:
    rmdup_bam_with_index:
      type: File
      outputSource: bind_bam_index/bam_with_index
    # bam:
    #   type: File
    #   outputSource: picard_rmdup/bam
    rmdup_metrics:
      type: File
      outputSource: picard_rmdup/metrics


