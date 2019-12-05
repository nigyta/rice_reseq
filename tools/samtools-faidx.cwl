#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: samtools-index-v1.9
label: samtools-index-v1.9

requirements:
    # InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/samtools:1.9--h10a08f8_12
    InitialWorkDirRequirement:
      listing: [ $(inputs.fasta) ]

baseCommand: [ samtools, faidx ]

inputs:
  fasta:
    type: File
    doc: Input FASTA file

arguments:
   - $(inputs.fasta)

outputs:
  - id: fai
    type: File
    outputBinding:
      glob: $(inputs.fasta.basename).fai

