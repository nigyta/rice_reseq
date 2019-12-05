#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: samtools-index-v1.9
label: samtools-index-v1.9

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/samtools:1.9--h10a08f8_12
    InitialWorkDirRequirement:
      listing: [ $(inputs.bam) ]

baseCommand: [ samtools, index ]

inputs:
  bam:
    type: File
    doc: Input BAM file
  threads:
    type: int
    default: 1
    inputBinding:
      prefix: -@

arguments:
   - $(inputs.bam)


outputs:
  - id: bai
    type: File
    outputBinding:
      glob: $(inputs.bam.basename).bai

