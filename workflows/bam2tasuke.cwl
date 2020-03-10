#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  bam:
    type: File
    doc: Input BAM file
    secondaryFiles:
      - .bai
  outprefix:
    type: string
    default: out
    doc: Prefix for output files

steps:

  tasuke_conv:
    run: ../tools/tasuke_bamtodepth/tasuke_bamtodepth.cwl 
    in:
      input_bam: bam
      output_file:
        source: outprefix
        valueFrom: ${ return self + "_tasuke_depth.tsv"}

    out: [tasuke_depth]

  gzip_tasuke_depth:
    run: ../tools/gzip.cwl
    in:
      input: tasuke_conv/tasuke_depth
    out: [gzipped_file]

  bam_header:
    run: ../tools/samtools-view-header.cwl
    in:
      bam: bam
    out: [header]

  make_chrom_bed:  # for BAM depth
    run: ../tools/awk-make-chr-bed.cwl
    in:
      input: bam_header/header
    out: [bed]

  bam_depth:
    run: ../tools/samtools-depth.cwl
    in:
      bam: bam
      bed: make_chrom_bed/bed
    out: [depth]

  get_avg_depth:
    run: ../tools/awk-get-ave-depth.cwl
    in:
      input: bam_depth/depth
      output:
        source: outprefix
        valueFrom: ${ return self + ".rmdup.bam.avg-depth.txt"}
    out: [avg_depth]

outputs:
  tasuke_depth:
    type: File
    outputSource: gzip_tasuke_depth/gzipped_file

  avg_depth:
    type: File
    outputSource: get_avg_depth/avg_depth
