#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}
  
inputs:
  bam:
    type: File
    secondaryFiles:
      - .bai
  reference:
    type: File
    doc: FASTA file for reference genome
    secondaryFiles:
      - ^.dict
      - .fai
  outprefix:
    type: string
    doc: Any string that can distinguish sample.
  threads:
    type: int
    default: 1

steps:
  bamfilter:
    run: bamfilter_wf.cwl
    in:
      bam: bam
      outprefix: outprefix
    out: [properbam_with_index, inproperbam_with_index]

  haplotype_caller:
    run: ../tools/gatk-HaplotypeCaller.cwl
    in:
      input: bamfilter/properbam_with_index
      reference: reference
      output: 
        source: outprefix
        valueFrom: variants_$(self).g.vcf.gz
      emit-ref-conf:
        valueFrom: BP_RESOLUTION
    out: [vcf]

      
  genotype_gvcf:
    run: ../tools/gatk-GenotypeGVCFs.cwl
    in:
      variant: haplotype_caller/vcf
      reference: reference
      output: 
        source: outprefix
        valueFrom: ${ return "variants_" + self + ".vcf.gz"}
    out: [vcf]




outputs:
    hc_gvcf:
      type: File
      outputSource: haplotype_caller/vcf
    non_filter_vcf:
      type: File
      outputSource: genotype_gvcf/vcf
    properbam:
      type: File
      outputSource: bamfilter/properbam_with_index
    inproperbam:
      type: File
      outputSource: bamfilter/inproperbam_with_index
