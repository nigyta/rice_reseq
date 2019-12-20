# How to run the RAPDB pipeline 

## Download reference files
```
$ ./download_reference_files.sh
```
Genome Fasta, Annotation GTF, and Protein Fasta are downloaded to `ref` directory.

## Run
- Help  
  ```
  cwltool ../workflows/rapdb-pipeline.cwl -h
  ```
- Run  
  All the output files will be generated into the directory specified with `--outdir`. If not specified, files will be generated into the current directory.
  ```
  cwltool --outdir test_out ../workflows/rapdb-pipeline.cwl --fastq1 read1.fq.gz --fastq2 read2.fq.gz --outprefix SAMDxxxxxxx --threads 2 --reference ref/IRGSP-1.0_genome_M_C_unanchored.fa --ref_gtf ref/RAP-DB_MSU_concatenated_for_snpEff.gtf --ref_protein ref/RAP-DB_MSU_concatenated_protein.fa
  ```
  or specifying a `job.yaml` file
  ```
  cwltool --outdir test_out ../workflows/rapdb-pipeline.cwl rapdb-pipeline.test.job.yaml 
  ```
- Run with singularity (NIG-SC)  
  Use `--singularity`. Singularity image files will be generated into the current directory. It is recommended to run the pipeline in the same working directory to avoid generating redundant image files.
  ```
  cwltool --singularity --outdir test_out ../workflows/rapdb-pipeline.cwl --fastq1 read1.fq.gz --fastq2 read2.fq.gz --outprefix SAMDxxxxxxx --threads 2 --reference ref/IRGSP-1.0_genome_M_C_unanchored.fa --ref_gtf ref/RAP-DB_MSU_concatenated_for_snpEff.gtf --ref_protein ref/RAP-DB_MSU_concatenated_protein.fa
- For debugging (Use `cachedir` to keep cache files and resume the job)
  ```
  cwltool --cachedir test_cache --outdir test_out ../workflows/rapdb-pipeline.cwl --fastq1 read1.fq.gz --fastq2 read2.fq.gz --outprefix SAMDxxxxxxx --threads 2 --reference ref/IRGSP-1.0_genome_M_C_unanchored.fa --ref_gtf ref/RAP-DB_MSU_concatenated_for_snpEff.gtf --ref_protein ref/RAP-DB_MSU_concatenated_protein.fa 
  ```

## Misc
- Create depth file for Tasuku+  
  `tasuku_bamtodepth.cwl` now runs locally without using docker. Make sure that Samtools must be installed and be in the `PATH` environmental variable.  
