#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: picard-MergeVcfs-v2.18.17
label: picard-MergeVcfs-v2.18.17

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/picard:2.18.17--0


baseCommand: [java, -jar, /usr/local/share/picard-2.18.17-0/picard.jar, MergeVcfs]

inputs:
  input_vcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false
    secondaryFiles:
      - .tbi
  # homo_snp:
  #   type: File
  #   inputBinding:
  #     prefix: INPUT=
  #     separate: false
  # hetero_snp:
  #   type: File
  #   inputBinding:
  #     prefix: INPUT=
  #     separate: false
  # homo_indel:
  #   type: File
  #   inputBinding:
  #     prefix: INPUT=
  #     separate: false
  # hetero_indel:
  #   type: File
  #   inputBinding:
  #     prefix: INPUT=
  #     separate: false
  merged_vcf:
    type: string
    default: merged.vcf
    inputBinding:
      prefix: OUTPUT=
      separate: false

arguments: []

outputs:
  vcf:
    type: File
    outputBinding:
      glob: $(inputs.merged_vcf)
    secondaryFiles:
      - .tbi