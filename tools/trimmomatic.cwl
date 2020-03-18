#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

id: trimmomatic-v0.38
label: trimmomatic-v0.38

requirements:
    InlineJavascriptRequirement: {}
    DockerRequirement:
        dockerPull: quay.io/biocontainers/trimmomatic:0.38--1


baseCommand: [trimmomatic, PE]
inputs:
  fastq1:
    type: File
  fastq2:
    type: File
  adapter:
    type: File
  outprefix:
    type: string
    default: "out"
  threads:
    type: int
    default: 1
    
arguments:
  - -threads
  - $(inputs.threads)
  - -phred33
  - -trimlog
  - $(inputs.outprefix).trimmomatic.log.txt
  - -summary
  - $(inputs.outprefix).trimmomatic.summary.txt
  - $(inputs.fastq1)
  - $(inputs.fastq2)  
  - $(inputs.fastq1.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, '')).trimmomatic-pe.fastq.gz
  - $(inputs.fastq1.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, '')).trimmomatic-se.fastq.gz
  - $(inputs.fastq2.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, '')).trimmomatic-pe.fastq.gz
  - $(inputs.fastq2.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, '')).trimmomatic-se.fastq.gz
  - ILLUMINACLIP:$(inputs.adapter.path):2:30:10
  - LEADING:20
  - TRAILING:20
  - SLIDINGWINDOW:10:20
  - MINLEN:30

outputs:
  pe1:
    type: File
    outputBinding:
      glob: $(inputs.fastq1.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, '')).trimmomatic-pe.fastq.gz
  pe2:
    type: File
    outputBinding:
      glob: $(inputs.fastq2.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, '')).trimmomatic-pe.fastq.gz
  se1:
    type: File
    outputBinding:
      glob: $(inputs.fastq1.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, '')).trimmomatic-se.fastq.gz
  se2:
    type: File
    outputBinding:
      glob: $(inputs.fastq2.basename.replace(/\.gz$|\.bz2$/, '').replace(/\.fq$|\.fastq$/, '')).trimmomatic-se.fastq.gz
  # log:
  #   type: File
  #   outputBinding:
  #     glob: $(inputs.outprefix).trimmomatic.log.txt
  summary:
    type: File
    outputBinding:
      glob: $(inputs.outprefix).trimmomatic.summary.txt
