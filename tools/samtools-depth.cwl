#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: samtools-depth-v1.9
label: samtools-depth-v1.9

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/samtools:1.9--h10a08f8_12


baseCommand: [ samtools, depth]  # add -a to output non-mapped region

inputs:
  bam:
    type: File
    doc: Input BAM file
    inputBinding:
      position: 2

  bed:
    type: File
    doc: BED file describing chromosome length
    inputBinding:
      position: 1
      prefix: -b

arguments: []


stdout: $(inputs.bam.basename).depth.txt

outputs:
  - id: depth
    type: stdout

