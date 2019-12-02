#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: picard-MarkDuplicates-v2.18.17
label: picard-MarkDuplicates-v2.18.17

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/picard:2.18.17--0


baseCommand: [picard, MarkDuplicates]

inputs:
  input:
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false
    doc: Input BAM file
  out_rmdup_bam:
    type: string
    default: alignment.rmdum.bam
    inputBinding:
      prefix: OUTPUT=
      separate: false
    doc: Output BAM file name
  out_metrics_file:
    type: string
    default: rmdum.metrics
    inputBinding:
      prefix: METRICS_FILE=
      separate: false
    secondaryFiles:
      - $(self.nameroot).dict

arguments:
  - id: remove_duplicates_flag
    valueFrom: "REMOVE_DUPLICATES=true"
  - id: max_records_in_ram
    valueFrom: "MAX_RECORDS_IN_RAM=1000000"
  - id: tmp_dir
    valueFrom: "TMP_DIR=./tmp"
  

outputs:
  bam:
    type: File
    outputBinding:
      glob: $(inputs.out_rmdup_bam)
  metrics:
    type: File
    outputBinding:
      glob: $(inputs.out_metrics_file)
