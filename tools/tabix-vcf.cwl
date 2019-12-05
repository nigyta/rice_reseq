#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: tabix-vcf
label: tabix-vcf

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/tabix:0.2.6--ha92aebf_0
    InitialWorkDirRequirement:
      listing: [ $(inputs.vcf) ]

baseCommand: [ tabix, -p, vcf ]

inputs:
  vcf:
    type: File
    doc: Input VCF.gz file

arguments:
   - $(inputs.vcf)

outputs:
  - id: tbi
    type: File
    outputBinding:
      glob: $(inputs.vcf.basename).tbi

