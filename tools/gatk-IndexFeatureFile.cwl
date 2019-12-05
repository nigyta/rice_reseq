#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: gatk-IndexFeatureFile-v4.0.11.0
label: gatk-IndexFeatureFile-v4.0.11.0

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: broadinstitute/gatk:4.0.11.0


baseCommand: [ gatk, IndexFeatureFile ]

inputs:
  featurefile:
    type: File
    doc: Input VCF file
    inputBinding:
      prefix: --feature-file


arguments:
  - id: output
    prefix: --output
    valueFrom: $(inputs.featurefile.basename).tbi

outputs:
  tbi:
    type: File
    outputBinding:
      glob: $(inputs.featurefile.basename).tbi
