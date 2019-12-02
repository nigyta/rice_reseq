#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: picard-CreateSequenceDictionary-v2.18.17
label: picard-CreateSequenceDictionary-v2.18.17

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/picard:2.18.17--0


baseCommand: [picard, CreateSequenceDictionary]

inputs:
  ref_fasta:
    type: File
    inputBinding:
      prefix: "REFERENCE="
      separate: false
#  out_dictionary:
#    type: string
#    default: genome.dict
#    inputBinding:
#      prefix: OUTPUT=
#      separate: false

arguments:
  - id: out_dictionary
    # prefix: -OUTPUT
    # valueFrom: "$(inputs.ref_fasta.nameroot).dict"
    valueFrom: "OUTPUT=$(inputs.ref_fasta.nameroot).dict"
      
outputs:
  dict:
    type: File
    outputBinding:
      glob: $(inputs.ref_fasta.nameroot).dict
