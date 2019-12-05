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

steps:
  haplotype_caller:
    run: ../tools/gatk-HaplotypeCaller.cwl
    in:
      input: bam
      reference: reference
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
    gvcf:
      type: File
      outputSource: select_variants/vcf

