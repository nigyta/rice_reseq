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
      # - ^.dict
      - $(self.nameroot).dict
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

  sort_sam:
    run: ../tools/samtools-sort.cwl
    in:
      bam: sam2bam/bam
      threads: threads
    out: [bam]

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
      aligned: sort_sam/bam
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
        # source: bwa_mem/sam
        # valueFrom: ${ return self.nameroot + ".rmdup.bam"}
        source: outprefix
        valueFrom: ${ return self + ".rmdup.bam"}
      out_metrics_file:
        source: outprefix
        valueFrom: ${ return self + ".rmdup.metrics"}
    out: [bam, metrics]

outputs:
    sorted_bam:
      type: File
      outputSource: sort_sam/bam
    bam:
      type: File
      outputSource: picard_rmdup/bam
    metrics:
      type: File
      outputSource: picard_rmdup/metrics


