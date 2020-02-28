#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: picard-SamToFastq-v2.18.17
label: picard-SamToFastq-v2.18.17

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/picard:2.18.17--0


baseCommand: [java, -jar, /usr/local/share/picard-2.18.17-0/picard.jar, SamToFastq, VALIDATION_STRINGENCY=SILENT]

inputs:
  bam:
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false
  unmapped_fastq1:
    type: string
    default: unmapped_read.r1.fastq
    inputBinding:
      prefix: FASTQ=
      separate: false
  unmapped_fastq2:
    type: string
    default: unmapped_read.r2.fastq
    inputBinding:
      prefix: SECOND_END_FASTQ=
      separate: false
  # unmapped_fastq_unpaired:
  #   type: string
  #   default: unmapped_read.unpaired.fastq
  #   inputBinding:
  #     prefix: UNPAIRED_FASTQ=
  #     separate: false

arguments: []

outputs:
  out_unmapped_fastq1:
    type: File
    outputBinding:
      glob: $(inputs.unmapped_fastq1)
  out_unmapped_fastq2:
    type: File
    outputBinding:
      glob: $(inputs.unmapped_fastq2)
  # unmapped_fastq_unpaired:
  #   type: File
  #   outputBinding:
  #     glob: $(inputs.unmapped_fastq_unpaired)
