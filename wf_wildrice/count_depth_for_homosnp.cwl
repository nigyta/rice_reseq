#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: python:slim


baseCommand: [python]
arguments:
  # python count_depth_for_homosnp.py input.vcf output.txt
  - $(inputs.script)
  - $(inputs.vcf)
  - $(inputs.outfile)

inputs:
    script:
      type: File
      default:
        class: File
        location: count_depth_for_homosnp.py
    vcf:
      type: File
      inputBinding:

    outfile:
      type: string

# stdout: proportion.txt

outputs:
  avg_depth:
    type: int
    outputBinding:
       glob: $(inputs.outfile)
       loadContents: True
       outputEval: $(parseInt(self[0].contents.split('\t')[1]))

  avg_depth_file:
    type: File
    outputBinding:
       glob: $(inputs.outfile)
