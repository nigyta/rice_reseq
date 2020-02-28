#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: samtools-get-unmapped-v1.9
label: samtools-get-unmapped-v1.9

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/samtools:1.9--h10a08f8_12


baseCommand: [ samtools, view, -f, "4" ]

inputs:
  bam:
    type: File
    doc: Input SAM file
  threads:
    type: int
    default: 1
    inputBinding:
      prefix: -@
  outbam:
    type: string
    doc: Output BAM file name for unmapped reads
    inputBinding:
      prefix: -o

arguments:
   - $(inputs.bam)

outputs:
  unmapped_read_bam:
    type: File
    outputBinding:
      glob: $(inputs.outbam)


