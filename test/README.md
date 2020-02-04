# How to run the RAPDB pipeline 

## Prerequisite
- Python3 and pip (required to install cwltool by `pip install cwltool`)
- cwltool
- samtools, awk, perl (required to create a depth file for Tasuke+)

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
- Run using singularity (NIG-SC)  
  Use `--singularity`. Singularity image files will be generated into the current directory. It is recommended to run the pipeline in the same working directory to avoid generating redundant image files.
  ```
  cwltool --singularity --outdir test_out ../workflows/rapdb-pipeline.cwl --fastq1 read1.fq.gz --fastq2 read2.fq.gz --outprefix SAMDxxxxxxx --threads 2 --reference ref/IRGSP-1.0_genome_M_C_unanchored.fa --ref_gtf ref/RAP-DB_MSU_concatenated_for_snpEff.gtf --ref_protein ref/RAP-DB_MSU_concatenated_protein.fa
- For debugging (Use `cachedir` to keep cache files and to resume the job)
  ```
  cwltool --cachedir test_cache --outdir test_out ../workflows/rapdb-pipeline.cwl --fastq1 read1.fq.gz --fastq2 read2.fq.gz --outprefix SAMDxxxxxxx --threads 2 --reference ref/IRGSP-1.0_genome_M_C_unanchored.fa --ref_gtf ref/RAP-DB_MSU_concatenated_for_snpEff.gtf --ref_protein ref/RAP-DB_MSU_concatenated_protein.fa 
  ```
- Run without making depth data for Tasuke+   
  If the depth file for Tasuke+ is not required, use `rapdb-pipeline_wo_tasuke.cwl`.
  ```
  cwltool --outdir test_out ../workflows/rapdb-pipeline_wo_tasuke.cwl --fastq1 read1.fq.gz --fastq2 read2.fq.gz --outprefix SAMDxxxxxxx --threads 2 --reference ref/IRGSP-1.0_genome_M_C_unanchored.fa --ref_gtf ref/RAP-DB_MSU_concatenated_for_snpEff.gtf --ref_protein ref/RAP-DB_MSU_concatenated_protein.fa
  ```
  or
  ```
  cwltool --outdir test_out ../workflows/rapdb-pipeline_wo_tasuke.cwl rapdb-pipeline.test.job.yaml 
  ```


## Options
|  Name  |  Description  | Mandatory / (default) |
| ---- | ---- | ---- |
|  --fastq1  |  FASTQ file for the forward read  | YES |
|  --fastq2  |  FASTQ file for the reverse read  | YES |
|  --reference  |  FASTA file for the reference genome  | YES |
|  --ref_gtf  |  Reference annotation in GTF for snpEff  | YES |
|  --ref_protein  |  Reference protein FASTA for snpEff  | YES |
|  --outprefix  |  Prefix for the output file  | (out) |
|  --threads  |  Number of threads for parallel processing | (1) |

Reference files (genomic FASTA, protein FASTA, GTF) can retrieved using `download_reference_files.sh`.

## Workflow
See [Analysis workflow for detection of genome-wide variations in TASUKE+ of RAP-DB](https://rapdb.dna.affrc.go.jp/genome-wide_variations/Analysis_workflow_for_detection_of_genome-wide_var.html)  
Files in the brackets ([ ]) will be output in the result directory.


1. Read preprocessing (read_preprocessing.cwl)  
    1.1 FASTQ stats for raw reads (seqkit stats) __[stats report]__  
    1.2 Adapter trimming and read QC (Trimmomatic) __[summary, log]__  
    1.3 Read quality check (FastQC) __[Report HTML]__  
    1.4 FASTQ stats for preprocessed reads (seqkit stats) __[stats report]__  
2. Read mapping and BAM conversion (fastq2bam.cwl)  
    2.1 Read mapping (BWA)  
    2.2 Convert SAM to BAM (samtools)  
    2.3 Sort BAM (samtools)  
    2.4 Create unmapped BAM (Picard FastqToSam)  
    2.5 Merge mapped and unmapped BAM (Picard Merge)  
    2.6 Remove duplicated reads (Picard MarkDuplicate) __[BAM, metrics file]__  
    2.7 Calculate depth from de-duplicated BAM (samtools depth) __[depth.txt]__  
    2.8 Create BAM index (samtools index) __[BAM index (.bai)]__  
3. Variant calling, genotyping, filtering (bam2vcf.cwl)  
    3.1 Variant calling (GATK HaplotypeCaller) __[gVCF, tbi]__  
    3.2 Genotyping (GATK GenotypeGVCFs)  
    3.3 Filtering (GATK VariantFiltration)   
        Filtering condition: "QD < 5.0 || FS > 50.0 || SOR > 3.0 || MQ < 50.0 || MQRankSum < -2.5 || ReadPosRankSum < -1.0 || ReadPosRankSum > 3.5"  
    3.4 Variant selection for SNP and INDEL (GATK SelectVariants) __[VCF, tbi]__  
4. Variant Annotation (snpeff_all.cwl)  
    4.1 Build SnpEff database from reference files (SnpEff build)  
    4.2 Annotate variants (SnpEff) __[VCF, tbi, summary, effected genes]__  
5. Make depth data for TASUKE+ (tasuke_bamtodepth.cwl) __[Tasuke+ depth file]__   
   

## Output
|  File name  |  Description  | Step |
| ---- | ---- | --- |
| {outprefix}_read-stats-raw.tsv | Stats file for raw FASTQ files | 1.1 |
| {outprefix}.trimmomatic.log.txt | Log file for Trimmomatic | 1.2 |
| {outprefix}.trimmomatic.summary.txt | Summary of Trimmomatic result | 1.2 |
| {fastq1,2}.pe_fastqc.html | FastQC report file for the read processed using Trimmomatoc | 1.3 |
| {outprefix}_read-stats.tsv | Stats file for preprocessed FASTQ files | 1.4 |
| {outprefix}.rmdup.bam | Alignment result in BAM format, after de-duplication | 2.6 |
| {outprefix}.rmdup.bam.bai | BAM index for the file above | 2.8 |
| {outprefix}.rmdup.metrics | Metrics file for BAM de-duplication | 2.6 |
| {outprefix}.rmdup.depth.txt | Depth file for de-duplicated BAM (generated using samtools-depth) | 2.7 |
| variants_{outprefix}.g.vcf.gz | gVCF file generated from GATK-HapolotypeCaller | 3.1 |
| variants_{outprefix}.g.vcf.gz.tbi | Tab index for the file above | 3.1 |
| variants_{outprefix}.varonly.vcf.gz | VCF file genotyped, filtered, and selected for variants | 3.4 |
| variants_{outprefix}.varonly.vcf.gz.tbi | Tab index for the file above | 3.4 |
| variants_{outprefix}.snpEff.vcf.gz | VCF file annotated using snpEFff | 4.2 |
| variants_{outprefix}.snpEff.vcf.gz.tbi | Tab index for the file above | 4.2 |
| snpEff_genes_{outprefix}.txt | snpEff result for effected genes| 4.2 |
| snpEff_summary_{outprefix}.html | Summary of snpEff | 4.2 |
| tasuke_depth_{outprefix}.tsv | Depth file for Tasuke+ | 5 |

## Misc
- Create depth file for Tasuku+  
  `tasuku_bamtodepth.cwl` now runs locally without using docker. Make sure that Samtools must be installed and be in the `PATH` environmental variable.  
