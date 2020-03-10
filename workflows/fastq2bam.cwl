#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  reference:
    type: File
    doc: FASTA file for reference genome
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - $(self.nameroot).dict
      # - ^.dict
  fastq1:
    type: File
    doc: Input FASTQ file for Read-1 (forward)
  fastq2:
    type: File
    doc: Input FASTQ file for Read-2 (reverse)
  outprefix:
    type: string
    doc: Any string that can distinguish sample.
  threads:
    type: int
    default: 1
    doc: Number of threads for parallel processing

steps:
  bwa_mem:
    run: ../tools/bwa-mem.cwl
    in:
      reference: reference
      fastq1: fastq1
      fastq2: fastq2
      outprefix: outprefix
      threads: threads
    out: [sam, log]

  sam2bam:
    run: ../tools/samtools-sam2bam.cwl
    in:
      sam: bwa_mem/sam
      threads: threads
    out: [bam]

  sort_bam:
    run: ../tools/samtools-sort.cwl
    in:
      bam: sam2bam/bam
      threads: threads
    out: [sorted_bam]

  picard_fastq2sam:
    run: ../tools/picard-FastqToSam.cwl
    in:
      fastq1: fastq1
      fastq2: fastq2
      out_unmapped_bam:
        source: outprefix
        valueFrom: ${ return self + ".uBAM.bam"}
      sample_id: outprefix
    out: [bam]

  picard_merge:
    run: ../tools/picard-MergeBamAlignment.cwl
    in:
      aligned: sort_bam/sorted_bam
      unmapped: picard_fastq2sam/bam
      reference: reference
      out_merged_bam:
        source: outprefix
        valueFrom: ${ return self + ".merge.bam"}
    out: [bam]

  get_unmapped_bam:
    run: ../tools/samtools-get-unmapped.cwl 
    in:
      bam: picard_merge/bam
      threads: threads
      outbam:
        source: outprefix
        valueFrom: ${ return self + ".unmapped-read.bam"}
    out: [unmapped_read_bam]
    
  get_unmapped_fastq:
    run: ../tools/picard-SamToFastq.cwl
    in:
      bam: get_unmapped_bam/unmapped_read_bam
      unmapped_fastq1:
        source: outprefix
        valueFrom: ${ return self + ".unmapped-read.r1.fastq"}
      unmapped_fastq2:
        source: outprefix
        valueFrom: ${ return self + ".unmapped-read.r2.fastq"}
      # unmapped_fastq_unpaired:
      #   source: outprefix
      #   valueFrom: ${ return self + ".unmapped-read.unpaired.fastq"}
    # out: [unmapped_fastq1, unmapped_fastq2, unmapped_fastq_unpaired]
    out: [out_unmapped_fastq1, out_unmapped_fastq2]

  gzip_unmapped_fastq1:
    run: ../tools/gzip.cwl
    in:
      input: get_unmapped_fastq/out_unmapped_fastq1
    out: [gzipped_file]

  gzip_unmapped_fastq2:
    run: ../tools/gzip.cwl
    in:
      input: get_unmapped_fastq/out_unmapped_fastq2
    out: [gzipped_file]

  picard_rmdup:
    run: ../tools/picard-MarkDuplicates.cwl
    in:
      input: picard_merge/bam
      out_rmdup_bam: 
        source: outprefix
        valueFrom: ${ return self + ".rmdup.bam"}
      out_metrics_file:
        source: outprefix
        valueFrom: ${ return self + ".rmdup.metrics"}
    out: [bam, metrics]

  bam_stats:
    run: ../tools/samtools-stats.cwl
    in:
      bam: picard_rmdup/bam
    out: [stats]

  # bam_header:
  #   run: ../tools/samtools-view-header.cwl
  #   in:
  #     bam: picard_rmdup/bam
  #   out: [header]

  # make_chrom_bed:  # for BAM depth
  #   run: ../tools/awk-make-chr-bed.cwl
  #   in:
  #     input: bam_header/header
  #   out: [bed]

  # bam_depth:
  #   run: ../tools/samtools-depth.cwl
  #   in:
  #     bam: picard_rmdup/bam
  #     bed: make_chrom_bed/bed
  #   out: [depth]

  # get_avg_depth:
  #   run: ../tools/awk-get-ave-depth.cwl
  #   in:
  #     input: bam_depth/depth
  #     output:
  #       source: outprefix
  #       valueFrom: ${ return self + ".rmdup.bam.avg-depth.txt"}
  #   out: [avg_depth]

  bam_indexing:
    run: ../tools/samtools-index.cwl
    in:
      bam: picard_rmdup/bam
      threads: threads
    out: [bai]

  bind_bam_index:
    run: ../tools/util-bindBamIndex.cwl
    in:
      bam: picard_rmdup/bam
      bai: bam_indexing/bai
    out: [bam_with_index]


outputs:
    rmdup_bam_with_index:
      type: File
      outputSource: bind_bam_index/bam_with_index
    # bam:
    #   type: File
    #   outputSource: picard_rmdup/bam
    rmdup_metrics:
      type: File
      outputSource: picard_rmdup/metrics
    # depth:
    #   type: File
    #   outputSource: bam_depth/depth
    stats:
      type: File
      outputSource: bam_stats/stats
    # unmapped_read_bam:
    #   type: File
    #   outputSource: get_unmapped_bam/unmapped_read_bam
    unmapped_fastq1:
      type: File
      outputSource: gzip_unmapped_fastq1/gzipped_file
    unmapped_fastq2:
      type: File
      outputSource: gzip_unmapped_fastq2/gzipped_file
    # chrom_bed:
    #   type: File
    #   outputSource: make_chrom_bed/bed
    # unmapped_fastq_unpaired:
    #   type: File
    #   outputSource: get_unmapped_fastq/unmapped_fastq_unpaired


