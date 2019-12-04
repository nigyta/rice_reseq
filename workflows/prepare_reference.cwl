#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  reference:
    type: File

steps:
  bwa_index:
    run: ../tools/bwa-index.cwl
    in:
      reference: reference
    out: [amb, ann, bwt, pac, sa, log]

  create_dict:
    run: ../tools/picard-CreateSequenceDictionary.cwl
    in:
      reference: reference
    out: [dict]

outputs:
    bwa_index_amb:
      type: File
      outputSource: bwa_index/amb
    bwa_index_ann:
      type: File
      outputSource: bwa_index/ann
    bwa_index_bwt:
      type: File
      outputSource: bwa_index/bwt
    bwa_index_pac:
      type: File
      outputSource: bwa_index/pac
    bwa_index_sa:
      type: File
      outputSource: bwa_index/sa
    sequence_dict:
      type: File
      outputSource: create_dict/dict
