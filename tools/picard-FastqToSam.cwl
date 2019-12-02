#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: picard-FastqToBam-v2.18.17
label: picard-FastqToBam-v2.18.17

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/picard:2.18.17--0


baseCommand: [java, -jar, /usr/local/share/picard-2.18.17-0/picard.jar, FastqToSam]

inputs:
  fastq1:
    type: File
    inputBinding:
      prefix: FASTQ=
      separate: false
  fastq2:
    type: File
    inputBinding:
      prefix: FASTQ2=
      separate: false
  out_unmapped_bam:
    type: string
    default: uBAM.bam
    inputBinding:
      prefix: OUTPUT=
      separate: false
  sample_id:
    type: string

arguments:
  - id: read_group_name
    valueFrom: "READ_GROUP_NAME=$(inputs.sample_id)"
  - id: sample_name
    valueFrom: "SAMPLE_NAME=$(inputs.sample_id)"
  - id: library_name
    valueFrom: "LIBRARY_NAME=$(inputs.sample_id)"        

outputs:
  bam:
    type: File
    outputBinding:
      glob: $(inputs.out_unmapped_bam)
