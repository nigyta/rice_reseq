#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
requirements: {}
  # InlineJavascriptRequirement: {}
  # DockerRequirement:
  #   dockerPull: quay.io/biocontainers/bamclipper:1.0.0--1


baseCommand: [perl]
arguments: [$(inputs.script), -s, samtools]
inputs:
    script:
      type: File
      default:
        class: File
        location: tasuke_bamtodepth.pl
    chr_list:
      type: File
      default:
        class: File
        location: chromosome_list.csv
      inputBinding:
        prefix: -c
    input_bam:
      type: File
      inputBinding:
        prefix: -i
      secondaryFiles:
        - .bai
    output_file:
      type: string
      inputBinding:
        prefix: -o

outputs:
  tasuke_depth:
    type: File
    outputBinding:
       glob: $(inputs.output_file)