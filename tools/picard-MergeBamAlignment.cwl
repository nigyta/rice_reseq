#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: picard-MergeBamAlignment-v2.18.17
label: picard-MergeBamAlignment-v2.18.17

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/picard:2.18.17--0


baseCommand: [java, -jar, /usr/local/share/picard-2.18.17-0/picard.jar, MergeBamAlignment]

inputs:
  aligned:
    type: File
    inputBinding:
      prefix: ALIGNED=
      separate: false
  unmapped:
    type: File
    inputBinding:
      prefix: UNMAPPED=
      separate: false
  out_merged_bam:
    type: string
    default: alignment.merge.bam
    inputBinding:
      prefix: OUTPUT=
      separate: false
  reference:
    type: File
    inputBinding:
      prefix: REFERENCE_SEQUENCE=
      separate: false
    secondaryFiles:
      - $(self.nameroot).dict

arguments: []

outputs:
  bam:
    type: File
    outputBinding:
      glob: $(inputs.out_merged_bam)
