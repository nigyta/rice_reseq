#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: bwa-mem-v0.7.17
label: bwa-mem-v0.7.17

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: biocontainers/bwa:v0.7.17-3-deb_cv1

baseCommand: [ bwa, mem ]

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
  fastq1:
    type: File
  fastq2:
    type: File
  threads:
    type: int
    default: 1
    inputBinding:
      prefix: -t
  outprefix:
    type: string

arguments:
  - id: bwa_option
    valueFrom: -M
  - $(inputs.reference)
  - $(inputs.fastq1)  
  - $(inputs.fastq2) 

stdout: $(inputs.outprefix).sam
stderr: $(inputs.outprefix).sam.log 

outputs:
  - id: sam
    type: stdout
  - id: log
    type: stderr


