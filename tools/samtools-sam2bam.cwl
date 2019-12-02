#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: samtools-sam2bam-v1.9
label: samtools-sam2bam-v1.9

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/samtools:1.9--h10a08f8_12


baseCommand: [ samtools, view, -b ]

inputs:
  sam:
    type: File
    doc: Input SAM file
  threads:
    type: int
    default: 1
    inputBinding:
      prefix: -@

#    type: File
#    doc: Ouput BAM file name

arguments:
   - $(inputs.sam)


stdout: $(inputs.sam.nameroot).bam
# stderr: samtools.log 

outputs:
  - id: bam
    type: stdout
#  - id: loga
#    type: stderr

