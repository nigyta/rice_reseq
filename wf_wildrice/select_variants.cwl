#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: gatk-SelectVariants_for_wr-v4.0.11.0
label: gatk-SelectVariants_for_wr-v4.0.11.0

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: broadinstitute/gatk:4.0.11.0


baseCommand: [ gatk, --java-options, -Xmx4G, SelectVariants ]

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
    default: variants.snp.vcf.gz
    inputBinding:
      prefix: --output

  vartype:
    type: string
    doc: Type to include (SNP or INDEL)
    inputBinding:
      prefix: --select-type-to-include

  select:
    type: string?
    doc: Select Expressions [e.g. vc.getGenotype("sample").isHomVar() or isHet()]
    inputBinding:
      prefix: --selectExpressions

arguments:

outputs:
  vcf:
    type: File
    outputBinding:
      glob: $(inputs.output)
    secondaryFiles:
      - .tbi