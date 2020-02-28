#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: make chrom BED for depth-calculation
label: make chrom BED for depth-calculation

requirements:
  InlineJavascriptRequirement: {}

baseCommand: [ awk, '{sum+=$3} END { print "Average Depth of Coverage (rmdup.bam):",sum/NR}' ]

inputs:
  input: 
    type: File
    inputBinding:
      position: 1

  output:
    type: string
    default: avg_depth.txt

stdout: $(inputs.output)

outputs:
  - id: avg_depth
    type: stdout
