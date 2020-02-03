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

## Output
|  File name  |  Description  |
| ---- | ---- |
| {fastq}.pe_fastqc.html | FastQC report file for the read processed using Trimmpmatoc |
| {outprefix}.rmdup.bam | Alignment result in BAM format, after de-duplication |
| {outprefix}.rmdup.bam.bai | BAM index for the file above |
| {outprefix}.rmdup.metrics | Metrics file for BAM de-duplication |
| {outprefix}.rmdup.depth.txt | Depth file for de-duplicated BAM (generated using samtools-depth) |
| {outprefix}.trimmomatic.log.txt | Log file for Trimmomatic |
| {outprefix}.trimmomatic.summary.txt | Summary of Trimmomatic result |
| alignment_depth_{outprefix}.tsv | Coverage file for Tasuke+ |
| {outprefix}_read-stats-raw.tsv | Stats file for raw FASTQ files |
| {outprefix}_read-stats.tsv | Stats file for preprocessedless FASTQ files |
| snpEff_genes_{outprefix}.txt | snpEff result for effected genes|
| snpEff_summary_{outprefix}.html | Summary of snpEff |
| variants_{outprefix}.g.vcf.gz | gVCF file generated from GATK-HapolotypeCaller |
| variants_{outprefix}.g.vcf.gz.tbi | Tab index for the file above |
| variants_{outprefix}.varonly.vcf.gz | VCF file filtered for variants |
| variants_{outprefix}.varonly.vcf.gz.tbi | Tab index for the file above |
| variants_{outprefix}.snpEff.vcf.gz | VCF file annotated using snpEFff |
| variants_{outprefix}.snpEff.vcf.gz.tbi | Tab index for the file above |

## Misc
- Create depth file for Tasuku+  
  `tasuku_bamtodepth.cwl` now runs locally without using docker. Make sure that Samtools must be installed and be in the `PATH` environmental variable.  
