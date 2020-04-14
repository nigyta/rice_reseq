#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  vcf:
    type: File
    secondaryFiles:
      - .tbi
  reference:
    type: File
    doc: FASTA file for reference genome
    secondaryFiles:
      - ^.dict
      - .fai
  outprefix:
    type: string
    doc: Any string that can distinguish sample.
  filter-homo-snp:
    type: string
    doc: Filter condition for homo SNP
    default: "DP < 2 || QD < 2.0 || FS > 60.0 || MQ < 40.0 || SOR > 3.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0"
  filter-hetero-snp:
    type: string
    doc: Filter condition for hetero SNP (maximum DP cutoff will be automatically specified)
    default: "DP < 2 || QD < 2.0 || FS > 60.0 || MQ < 40.0 || SOR > 3.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0"
  filter-homo-indel:
    type: string
    doc: Filter condition for homo INDEL
    default: "DP < 2 || QD < 2.0 || FS > 200.0 || SOR > 3.0 || ReadPosRankSum < -20.0"
  filter-hetero-indel:
    type: string
    doc: Filter condition for hetero INDEL (maximum DP cutoff will be automatically specified)
    default: "DP < 2 || QD < 2.0 || FS > 200.0 || SOR > 3.0 || ReadPosRankSum < -20.0"

steps:
  # for homo SNPs
  select_homo_snp:
    run: select_variants.cwl
    in:
      variant: vcf
      reference: reference
      output: 
        source: outprefix
        valueFrom: variants_$(self).homo-snp.vcf.gz
      vartype:
        valueFrom: "SNP"
      select:
        source: outprefix
        valueFrom: 'vc.getGenotype("$(self)").isHomVar()'
    out: [vcf]

  filtration_homo_snp:
    run: ../tools/gatk-VariantFiltration.cwl
    in:
      variant: select_homo_snp/vcf
      reference: reference
      output:
        source: outprefix
        valueFrom: variants_$(self).homo-snp.filtertmp.vcf.gz
      filter-expression: filter-homo-snp
    out: [vcf]

  remove_filtered_homo_snp:
    run: ../tools/gatk-SelectVariants.cwl
    in:
      variant: filtration_homo_snp/vcf
      reference: reference
      output:
        source: outprefix
        valueFrom: variants_$(self).homo-snp.filtered.vcf.gz
    out: [vcf]

  count_depth_for_homo_snp:
    run: count_depth_for_homosnp.cwl
    in:
      vcf: remove_filtered_homo_snp/vcf
      outfile:
        source: outprefix
        valueFrom: $(self).depth.homosnp.txt
    out: [avg_depth, avg_depth_file]

  # for hetero SNPs
  select_hetero_snp:
    run: select_variants.cwl
    in:
      variant: vcf
      reference: reference
      output: 
        source: outprefix
        valueFrom: variants_$(self).hetero-snp.vcf.gz
      vartype:
        valueFrom: "SNP"
      select:
        source: outprefix
        valueFrom: 'vc.getGenotype("$(self)").isHet()'
    out: [vcf]

  filtration_hetero_snp:
    run: filtration_for_hetero.cwl
    in:
      variant: select_hetero_snp/vcf
      reference: reference
      output:
        source: outprefix
        valueFrom: variants_$(self).hetero-snp.filtertmp.vcf.gz
      filter_condition: filter-hetero-snp
      dp_cutoff: count_depth_for_homo_snp/avg_depth
    out: [vcf]

  remove_filtered_hetero_snp:
    run: ../tools/gatk-SelectVariants.cwl
    in:
      variant: filtration_hetero_snp/vcf
      reference: reference
      output:
        source: outprefix
        valueFrom: variants_$(self).hetero-snp.filtered.vcf.gz
      
    out: [vcf]

  # for homo INDELs
  select_homo_indel:
    run: select_variants.cwl
    in:
      variant: vcf
      reference: reference
      output: 
        source: outprefix
        valueFrom: variants_$(self).homo-indel.vcf.gz
      vartype:
        valueFrom: "INDEL"
      select:
        source: outprefix
        valueFrom: 'vc.getGenotype("$(self)").isHomVar()'

    out: [vcf]

  filtration_homo_indel:
    run: ../tools/gatk-VariantFiltration.cwl
    in:
      variant: select_homo_indel/vcf
      reference: reference
      output:
        source: outprefix
        valueFrom: variants_$(self).homo-indel.filtertmp.vcf.gz
      filter-expression: filter-homo-indel
    out: [vcf]

  remove_filtered_homo_indel:
    run: ../tools/gatk-SelectVariants.cwl
    in:
      variant: filtration_homo_indel/vcf
      reference: reference
      output:
        source: outprefix
        valueFrom: variants_$(self).homo-indel.filtered.vcf.gz
    out: [vcf]

  # for hetero INDELs
  select_hetero_indel:
    run: select_variants.cwl
    in:
      variant: vcf
      reference: reference
      output: 
        source: outprefix
        valueFrom: variants_$(self).hetero-indel.vcf.gz
      vartype:
        valueFrom: "INDEL"
      select:
        source: outprefix
        valueFrom: 'vc.getGenotype("$(self)").isHet()'

    out: [vcf]

  filtration_hetero_indel:
    run: filtration_for_hetero.cwl
    in:
      variant: select_hetero_indel/vcf
      reference: reference
      output:
        source: outprefix
        valueFrom: variants_$(self).hetero-indel.filtertmp.vcf.gz
      filter_condition: filter-hetero-indel
      dp_cutoff: count_depth_for_homo_snp/avg_depth
    out: [vcf]

  remove_filtered_hetero_indel:
    run: ../tools/gatk-SelectVariants.cwl
    in:
      variant: filtration_hetero_indel/vcf
      reference: reference
      output:
        source: outprefix
        valueFrom: variants_$(self).hetero-indel.filtered.vcf.gz
    out: [vcf]

  merge_vcfs:
    run: picard_MergeVcfs.cwl
    in:
      input_vcf: [remove_filtered_homo_snp/vcf, remove_filtered_hetero_snp/vcf, remove_filtered_homo_indel/vcf, remove_filtered_hetero_indel/vcf]
      merged_vcf: 
        source: outprefix
        valueFrom: variants_$(self).filtered.vcf.gz
    out: [vcf]

outputs:
    homo_snp_nonfilter:
      type: File
      outputSource: select_homo_snp/vcf
    homo_snp:
      type: File
      outputSource: remove_filtered_homo_snp/vcf

    hetero_snp_nonfilter:
      type: File
      outputSource: select_hetero_snp/vcf
    hetero_snp:
      type: File
      outputSource: remove_filtered_hetero_snp/vcf

    homo_indel_nonfilter:
      type: File
      outputSource: select_homo_indel/vcf
    homo_indel:
      type: File
      outputSource: remove_filtered_homo_indel/vcf

    hetero_indel_nonfilter:
      type: File
      outputSource: select_hetero_indel/vcf
    hetero_indel:
      type: File
      outputSource: remove_filtered_hetero_indel/vcf

    homo_snp_depth:
      type: File
      outputSource: count_depth_for_homo_snp/avg_depth_file

    merged_vcf:
      type: File
      outputSource: merge_vcfs/vcf