#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

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
  haplotype_caller:
    run: ../tools/gatk-HaplotypeCaller.cwl
    in:
      input: bam
      reference: reference
      output: 
        source: outprefix
        valueFrom: variants_$(self).g.vcf.gz
    out: [vcf]

      
  genotype_gvcf:
    run: ../tools/gatk-GenotypeGVCFs.cwl
    in:
      variant: haplotype_caller/vcf
      reference: reference
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
        valueFrom: ${ return "variants_" + self + ".varonly.vcf.gz"}

    out: [vcf]


outputs:
    hc_gvcf:
      type: File
      outputSource: haplotype_caller/vcf
    varonly_vcf:
      type: File
      outputSource: select_variants/vcf

