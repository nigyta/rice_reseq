#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: Bind FASTA and secondary files
label: Bind FASTA and secondary files

requirements:
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.fasta)
      - entry: $(inputs.fai)
      - entry: $(inputs.amb)
      - entry: $(inputs.ann)
      - entry: $(inputs.bwt)
      - entry: $(inputs.pac)
      - entry: $(inputs.sa)
      - entry: $(inputs.dict)

baseCommand: "true"

inputs:
  fasta: File
  fai: File
  amb: File
  ann: File
  bwt: File
  pac: File
  sa: File
  dict: File

outputs:
  fasta_with_index:
    type: File
    outputBinding:
      glob: $(inputs.fasta.basename)
    secondaryFiles:
      - .fai
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - ^.dict
