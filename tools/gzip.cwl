#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: gzip file
label: gzip file

requirements:
  InlineJavascriptRequirement: {}

baseCommand: [ gzip, -c ]

inputs:
  input: 
    type: File
    inputBinding:
      position: 1

stdout: $(inputs.input.basename).gz

outputs:
  gzipped_file:
    type: stdout
