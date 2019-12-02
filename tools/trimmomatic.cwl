#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: trimmomatic-v0.38
label: trimmomatic-v0.38

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/trimmomatic:0.38--1


baseCommand: [echo, trimmomatic, PE]
inputs:
  fastq1:
    type: File
  fastq2:
    type: File
  threads:
    type: int
    default: 1

arguments:
  - $(inputs.fastq1)
  - $(inputs.fastq2)  
  - $(inputs.fastq1.nameroot).pe.fastq.gz
  - $(inputs.fastq1.nameroot).se.fastq.gz
  - $(inputs.fastq2.nameroot).pe.fastq.gz
  - $(inputs.fastq2.nameroot).se.fastq.gz

outputs:
  output:
    type: stdout    