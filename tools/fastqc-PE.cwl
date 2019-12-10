#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: biocontainers/fastqc:v0.11.5_cv4

baseCommand: [fastqc]
arguments:
    - $(inputs.fastq1)
    - $(inputs.fastq2)
    - -o 
    - .

inputs:
    threads: 
      type: int?
      default: 1
      inputBinding:
        prefix: -t
    fastq1: File
    fastq2: File

outputs:
    result1:
       type: File
       outputBinding:
            glob: $(inputs.fastq1.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, ''))_fastqc.html
    result2:
        type: File
        outputBinding:
            glob: $(inputs.fastq2.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, ''))_fastqc.html
