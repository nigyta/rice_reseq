#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
requirements:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/snpeff:4.3.1t--3
  InlineJavascriptRequirement: {}

# snpEff   -v -c $BUILD_DIR/snpEff.config  $SNPEFF_DB_BASENAME  /data/SRR849476.varonly.vcf.gz

baseCommand: [snpEff]
arguments:
  - -Xmx4g
  - -v
  - -c
  - $(inputs.dbdir.path)/snpEff.config
  - $(inputs.dbname)
  - $(inputs.vcf)

inputs:
    vcf:
      type: File
    dbname:
      type: string
      default: RAP_MSU_on_IRGSP-1.0
    dbdir:
      type: Directory
    out_vcf:
      type: string
      default: snpeff.vcf
    outprefix:
      type: string?

outputs:
  vcf:
    type: stdout  
  genes:
    type: File
    outputBinding:
      glob: snpEff_genes.txt
      outputEval: ${
          if(inputs.outprefix === null){
            return self;
          } else {
            self[0].basename="snpEff_genes_" + inputs.outprefix + ".txt"; return self;
          }        
        }
  summary:
    type: File
    outputBinding:
      glob: snpEff_summary.html
      outputEval: ${
          if(inputs.outprefix === null){
            return self;
          } else {
            self[0].basename="snpEff_summary_" + inputs.outprefix + ".html"; return self;
          }        
        }

stdout: $(inputs.out_vcf)
