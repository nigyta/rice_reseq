#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: trimmomatic-v0.38
label: trimmomatic-v0.38

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/trimmomatic:0.38--1


baseCommand: [awk]
inputs:
  adapter: 
    type: string
    default: adapter.fasta



arguments:
  - "1"
  - /usr/local/share/trimmomatic-0.38-1/adapters/TruSeq3-PE-2.fa
  - /usr/local/share/trimmomatic-0.38-1/adapters/TruSeq3-SE.fa 

stdout: $(inputs.adapter)

outputs:
  adapter_fasta:
    type: stdout    