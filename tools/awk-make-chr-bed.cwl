#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: make chrom BED for depth-calculation
label: make chrom BED for depth-calculation

requirements:
  InlineJavascriptRequirement: {}

baseCommand: [ awk, '{if($1=="@SQ" && $2 ~ /^SN:chr[0-9]/){ gsub("SN:", "", $2); gsub("LN:", "", $3); print $2"\t1\t"$3}}' ]

inputs:
  input: 
    type: File
    inputBinding:
      position: 1

stdout: chromosome_list.bed

outputs:
  bed:
    type: stdout
