#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  reference:
    type: File
    doc: FASTA file for reference genome

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

  create_faidx:
    run: ../tools/samtools-faidx.cwl
    in:
      fasta: reference
    out:
      [fai]

  bind_fasta_index:
    run: ../tools/util-bindFastaIndex.cwl
    in:
      fasta: reference
      fai: create_faidx/fai
      amb: bwa_index/amb
      ann: bwa_index/ann
      bwt: bwa_index/bwt
      pac: bwa_index/pac
      sa: bwa_index/sa
      dict: create_dict/dict
    out:
      [fasta_with_index]

outputs:
    fasta_with_index:
      type: File
      outputSource: bind_fasta_index/fasta_with_index
    # bwa_index_amb:
    #   type: File
    #   outputSource: bwa_index/amb
    # bwa_index_ann:
    #   type: File
    #   outputSource: bwa_index/ann
    # bwa_index_bwt:
    #   type: File
    #   outputSource: bwa_index/bwt
    # bwa_index_pac:
    #   type: File
    #   outputSource: bwa_index/pac
    # bwa_index_sa:
    #   type: File
    #   outputSource: bwa_index/sa
    # sequence_dict:
    #   type: File
    #   outputSource: create_dict/dict
