#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: Bind BAM and index file
label: Bind BAM and index file

requirements:
  InitialWorkDirRequirement:
    listing:
    - entry: $(inputs.bam)
    - entry: $(inputs.bai)

baseCommand: "true"

inputs:
  bam: File
  bai: File

outputs:
  bam_with_index:
    type: File
    outputBinding:
      glob: $(inputs.bam.basename)
    secondaryFiles:
      - .bai
