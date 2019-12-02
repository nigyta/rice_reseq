#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: bwa-index-v0.7.17
label: bwa-index-v0.7.17

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: biocontainers/bwa:v0.7.17-3-deb_cv1


baseCommand: [ bwa, index ]

inputs:
  reference:
    type: File
    doc: FASTA file for reference genome

arguments:
  - id: ref_prefix
    prefix: -p
    valueFrom: $(inputs.reference.basename)
  - id: reference
    valueFrom: $(inputs.reference)

outputs:
  - id: amb
    type: File
    outputBinding:
      glob: $(inputs.reference.basename).amb
  - id: ann
    type: File
    outputBinding:
      glob: $(inputs.reference.basename).ann
  - id: bwt
    type: File
    outputBinding:
      glob: $(inputs.reference.basename).bwt
  - id: pac
    type: File
    outputBinding:
      glob: $(inputs.reference.basename).pac
  - id: sa
    type: File
    outputBinding:
      glob: $(inputs.reference.basename).sa
  - id: log
    type: stderr

stderr: $(inputs.reference.basename).bwa-index.log


