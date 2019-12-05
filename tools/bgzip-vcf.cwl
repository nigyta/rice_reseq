#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: bgzip file
label: bgzip file

requirements:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/tabix:0.2.6--ha92aebf_0
  InlineJavascriptRequirement: {}

baseCommand: [ bgzip, -c ]

inputs:
  vcf: 
    type: File
    inputBinding:
      position: 1

stdout: $(inputs.vcf.basename).gz

outputs:
  bgzipped_vcf:
    type: stdout
