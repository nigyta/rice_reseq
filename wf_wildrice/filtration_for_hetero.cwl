#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: gatk-VariantFiltration-v4.0.11.0
label: gatk-VariantFiltration-v4.0.11.0

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: broadinstitute/gatk:4.0.11.0


baseCommand: [ gatk, --java-options, -Xmx4G, VariantFiltration ]

inputs:
  variant:
    type: File
    doc: Input VCF file
    inputBinding:
      prefix: --variant
    secondaryFiles:
      - .tbi
  reference:
    type: File
    doc: Reference FASTA file
    inputBinding:
      prefix: --reference
    secondaryFiles:
      - .fai
      - ^.dict
  output:
    type: string
    doc: Output VCF file name
    default: variants.filter.genotype.vcf.gz
    inputBinding:
      prefix: --output
  
  filter_condition:
    type: string
    doc: Filter condition
    default: "QD < 5.0 || FS > 50.0 || SOR > 3.0 || MQ < 50.0 || MQRankSum < -2.5 || ReadPosRankSum < -1.0 || ReadPosRankSum > 3.5"

  dp_cutoff:
    type: int
    doc: Maximum DP threshold (mean depth of homo-SNPs)

arguments:
  - id: filter-name
    prefix: --filter-name
    valueFrom: FILTER
  - id: filter-string
    prefix: --filter-expression
    valueFrom: 'DP > $(parseInt(inputs.dp_cutoff)) || $(inputs.filter_condition)'

outputs:
  vcf:
    type: File
    outputBinding:
      glob: $(inputs.output)
    secondaryFiles:
      - .tbi