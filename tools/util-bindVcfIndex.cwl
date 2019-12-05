#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: Bind VCF.gz and tbi file
label: Bind VCF.gz and tbi file

requirements:
  InitialWorkDirRequirement:
    listing:
    - entry: $(inputs.vcf)
    - entry: $(inputs.tbi)

baseCommand: "true"

inputs:
  vcf: File
  tbi: File

outputs:
  vcfgz_with_tbi:
    type: File
    outputBinding:
      glob: $(inputs.vcf.basename)
    secondaryFiles:
      - .tbi
