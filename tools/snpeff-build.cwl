#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
requirements:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/snpeff:4.3.1t--3


baseCommand: [sh]
arguments:
  - $(inputs.script)
  - $(inputs.genome)
  - $(inputs.gtf)
  - $(inputs.protein)
  - $(inputs.dbname)
  - $(inputs.dbdir)

inputs:
    script:
      type: File
      default:
        class: File
        location: build_snpEff_db.sh
    genome:
      type: File
    gtf:
      type: File
    protein:
      type: File
    dbname:
      type: string
      default: RAP_MSU_on_IRGSP-1.0
    dbdir:
      type: string
      default: snpeff_db

outputs: 
  dbdir:
    type: Directory
    outputBinding:
      glob: $(inputs.dbdir)

