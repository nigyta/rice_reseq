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

outputs:
  tasuke_depth:
    type: File
    outputSource: gzip_tasuke_depth/gzipped_file

