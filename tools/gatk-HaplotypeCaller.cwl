#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: gatk-HaplotypeCaller-v4.0.11.0
label: gatk-HaplotypeCaller-v4.0.11.0

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: broadinstitute/gatk:4.0.11.0


baseCommand: [ gatk, --java-options, -Xmx4G, HaplotypeCaller ]

inputs:
  input:
    type: File
    doc: Input BAM file
    inputBinding:
      prefix: --input
    secondaryFiles:
      - .bai
  output:
    type: string
    doc: Output gVCF file name
    default: variants.g.vcf.gz
    inputBinding:
      prefix: --output
  reference:
    type: File
    doc: Reference FASTA file
    inputBinding:
      prefix: --reference
    secondaryFiles:
      - .fai
      - ^.dict
  emit-ref-conf:
    type: string
    doc: Mode for emitting reference confidence scores [GVCF(=default) or BP_RESOLUTION]
    default: GVCF
    inputBinding:
      prefix: --emit-ref-confidence
    

arguments:
  - id: max-alt-alleles
    prefix: -max-alternate-alleles
    valueFrom: "2"

outputs:
  vcf:
    type: File
    outputBinding:
      glob: $(inputs.output)
    secondaryFiles:
      - .tbi      