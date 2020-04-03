#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  InlineJavascriptRequirement: {}


inputs:
  bam:
    type: File
  outprefix:
    type: string
    doc: Any string that can distinguish sample.

steps:
    bamfilterpy:
      run: ../tools/bamfilter.cwl
      in:
        bam: bam
        outprefix: outprefix
      out: [properbam, inproperbam]

    bam_indexing:
      run: ../tools/samtools-index.cwl
      in:
        bam: bamfilterpy/properbam
      out: [bai]
  
    bind_bam_index:
      run: ../tools/util-bindBamIndex.cwl
      in:
        bam: bamfilterpy/properbam
        bai: bam_indexing/bai
      out: [bam_with_index]    

    bam_indexing_for_inproper:
      run: ../tools/samtools-index.cwl
      in:
        bam: bamfilterpy/inproperbam
      out: [bai]

    bind_bam_index_for_inproper:
      run: ../tools/util-bindBamIndex.cwl
      in:
        bam: bamfilterpy/inproperbam
        bai: bam_indexing_for_inproper/bai
      out: [bam_with_index]    

outputs:
    properbam_with_index:
      type: File
      outputSource: bind_bam_index/bam_with_index
    inproperbam_with_index:
      type: File
      outputSource: bind_bam_index_for_inproper/bam_with_index
      