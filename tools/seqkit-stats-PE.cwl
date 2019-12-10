#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
requirements:
    DockerRequirement:
        dockerPull: quay.io/biocontainers/seqkit:0.11.0--0

baseCommand: [seqkit, stats]
arguments:
    - $(inputs.fastq1)
    - $(inputs.fastq2)
inputs:
    fastq1: File
    fastq2: File
    stats_out:
      type: string?
      default: read-stats.txt
    threads: 
      type: int?
      default: 1
      inputBinding:
        prefix: --threads    

outputs:
  result:
    type: stdout  
stdout: $(inputs.stats_out)