#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: gatk-SelectVariants-v4.0.11.0
label: gatk-SelectVariants-v4.0.11.0

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: broadinstitute/gatk:4.0.11.0


baseCommand: [ gatk, SelectVariants ]

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
    doc: Output gVCF file name
    default: variants.filter.genotype.vcf.gz
    inputBinding:
      prefix: --output
  nthreads:
    type: int
    default: 1
    inputBinding:
      prefix: -nt


arguments:
  - id: option1
    prefix: --select-type-to-include
    valueFrom: "SNP"
  - id: option2
    prefix: --select-type-to-include
    valueFrom: "INDEL"
  - id: filter-name
    valueFrom: --exclude-filtered

outputs:
  vcf:
    type: File
    outputBinding:
      glob: $(inputs.output)
    secondaryFiles:
      - .tbi