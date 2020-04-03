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
  filter-expression:
    type: string
    doc: VCF filter condition for GATK-VariantFiltration
    default: "QD < 5.0 || FS > 50.0 || SOR > 3.0 || MQ < 50.0 || MQRankSum < -2.5 || ReadPosRankSum < -1.0 || ReadPosRankSum > 3.5"

steps:
  bamfilter:
    run: ../wf_wildrice/bamfilter_wf.cwl
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
        valueFrom: ${ return "variants_" + self + ".genotype.vcf.gz"}
    out: [vcf]

  variant_filtration:
    run: ../tools/gatk-VariantFiltration.cwl
    in:
      variant: genotype_gvcf/vcf
      reference: reference
      filter-expression: filter-expression
    out: [vcf]

  select_variants:
    run: ../tools/gatk-SelectVariants.cwl
    in:
      variant: variant_filtration/vcf
      reference: reference
      output:
        source: outprefix
        valueFrom: ${ return "variants_" + self + ".filtered.vcf.gz"}

    out: [vcf]


outputs:
    hc_gvcf:
      type: File
      outputSource: haplotype_caller/vcf
    non_filter_vcf:
      type: File
      outputSource: genotype_gvcf/vcf
    varonly_vcf:
      type: File
      outputSource: select_variants/vcf
    properbam:
      type: File
      outputSource: bamfilter/properbam_with_index
    inproperbam:
      type: File
      outputSource: bamfilter/inproperbam_with_index
