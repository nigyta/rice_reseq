#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  sam:
    type: File
  outprefix:
    type: string
    doc: Any string that can distinguish sample.
  threads:
    type: int
    default: 1
  reference:
    type: File
    doc: FASTA file for reference genome
    secondaryFiles:
      - ^.dict
      - .fai
steps:

  sam2bam:
    run: ../tools/samtools-sam2bam.cwl
    in:
      sam: sam
      threads: threads
    out: [bam]

  sort_bam:
    run: ../tools/samtools-sort.cwl
    in:
      bam: sam2bam/bam
      threads: threads
    out: [sorted_bam]

  bam_indexing:
    run: ../tools/samtools-index.cwl
    in:
      bam: sort_bam/sorted_bam
      threads: threads
    out: [bai]

  bind_bam_index:
    run: ../tools/util-bindBamIndex.cwl
    in:
      bam: sort_bam/sorted_bam
      bai: bam_indexing/bai
    out: [bam_with_index]

  haplotype_caller:
    run: ../tools/gatk-HaplotypeCaller.cwl
    in:
      input: bind_bam_index/bam_with_index
      reference: reference
    out: [vcf]


outputs:
    sorted_bam:
      type: File
      outputSource: bind_bam_index/bam_with_index
    vcf: 
      type: File
      outputSource: haplotype_caller/vcf

