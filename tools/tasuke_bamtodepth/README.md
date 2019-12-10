# tasuke_bamtodepth
## About this tool
`tasuke_bamtodepth.pl` is a utility script that converts a BAM file to a depth file for TASUKE+.
The script is obtained from the Tasuke+ Software Package.

## Docker Container
  Perl, awk, and samtools are required.  
  ~~It runs on the bamclipper docker.~~
    ~~`docker pull quay.io/biocontainers/bamclipper:1.0.0--1`~~
  As the Docker version was super slow, this runs locally without docker. Be sure to samtools is in 'PATH'.

## command
```
$ perl tasuke_bamtodepth.pl \
    -s samtools -c chromosome_list.csv -i alignment.rmdup.bam \
    -o alignment_depth.tsv
```
*.bam.bai must be placed in the same place as *.bam.

- chromosome_list.tsv  
```
$ cat chromosome_list.csv
chr01,43270923,16610866,17243770
chr02,35937250,13541821,13872411
chr03,36413819,19431743,19745569
chr04,35502694,9744480,9973218
chr05,29958434,12390387,12627019
chr06,31248787,15332004,15555636
chr07,29697621,11887856,12272916
chr08,28443022,12847483,13061068
chr09,23012720,2749793,3043847
chr10,23207287,8082722,8309866
chr11,29021106,12039480,12482616
chr12,27531856,11761737,12103486
```