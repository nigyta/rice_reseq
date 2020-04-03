#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: bamfilter
label: bamfilter

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/pysam:0.15.4--py37hbcae180_0


baseCommand: [ python ]

inputs:
  script:
    type: File
    default:
        class: File
        location: bamfilter.py     
  bam:
    type: File
    doc: Input BAM file
  outprefix:
    type: string
    default: out


arguments:
   - $(inputs.script)
   - $(inputs.bam)
   - $(inputs.outprefix)


outputs:
  - id: properbam
    type: File
    outputBinding:
      glob: $(inputs.outprefix).proper.bam
  - id: inproperbam
    type: File
    outputBinding:
       glob: $(inputs.outprefix).inproper.bam


