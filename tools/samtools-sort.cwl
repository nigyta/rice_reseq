#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: samtools-sort-v1.9
label: samtools-sort-v1.9

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/samtools:1.9--h10a08f8_12


baseCommand: [ samtools, sort ]

inputs:
  bam:
    type: File
    doc: Input BAM file
  threads:
    type: int
    default: 1
    inputBinding:
      prefix: -@
  memory:
    type: string
    default: 2G
    doc: Maximum memory per thread; suffix K/M/G recognized
    inputBinding:
      prefix: -m

arguments:
   - $(inputs.bam)


stdout: $(inputs.bam.nameroot).sort.bam
# stderr: samtools.log 

outputs:
  - id: sorted_bam
    type: stdout
#  - id: log
#    type: stderr

