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
  reference:
    type: File
    inputBinding:
      prefix: "REFERENCE="
      separate: false

arguments:
  - id: out_dictionary
    valueFrom: "OUTPUT=$(inputs.reference.nameroot).dict"
      
outputs:
  dict:
    type: File
    outputBinding:
      glob: $(inputs.reference.nameroot).dict
