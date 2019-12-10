#!/usr/bin/perl -w

#
# tasuke_bamtodepth.pl
# http://tasuke.dna.affrc.go.jp/
#
# Author: Ryutaro Itoh
#
# Copyright (c) 2013 National Institute of Agrobiological Sciences   
#

use strict;
use Getopt::Long;
use File::Basename;
use File::Copy;
use Cwd;

my $SAMTOOLS = "";
my $OUTDIR = "";
my $CHRLIST = "";
my $BAM = "";
my $baseq=0;
my $mapq=0;
my $opt="";

################################################################
# Checking parameters and database connection
################################################################
GetOptions( 's|samtools=s'      => \$SAMTOOLS,
            'o|outdir=s'     => \$OUTDIR,
            'c|chr=s'        => \$CHRLIST,
            'bq|base_quality=i'     => \$baseq,
            'mq|map_quality=i'        => \$mapq,
            'i|inbam=s'      => \$BAM     
);

if ($SAMTOOLS eq "" || $OUTDIR eq "" || $CHRLIST eq "" || $BAM eq "") {
    _error_method();  
    exit;
}
if(!defined $baseq || $baseq !~ /\d+/ ){
    $baseq=0;
}
if(!defined $mapq  || $mapq !~ /\d+/ ){
    $mapq=0;
}
if($baseq >0){
    $opt = $opt." -q ".$baseq;
}
if($mapq >0){
    $opt= $opt." -Q ".$mapq;
}

###########################################################
# Creating depth files 
###########################################################
# Set chromosomes 
my $OUTFILE=$OUTDIR;
$OUTDIR=$OUTDIR."_TMP";
my $loadchr_rt = _loadchr($CHRLIST);
_print_time(" Begin creating depth files");
my $rt_crtbam =_crtBam($BAM, $OUTDIR, $SAMTOOLS, $loadchr_rt);
_createDepth($rt_crtbam, $OUTDIR, $SAMTOOLS, $loadchr_rt, $opt, $BAM, $OUTFILE);
_print_time(" complete!");



###########################################################
# Loading chromosome list
###########################################################
sub _loadchr{
    my $CHRLIST = shift;
    my @CHR;
    my $max = 0;
    open IN, '<', $CHRLIST or die "file open error: $!";
    while (<IN>) {
        chomp;
        my @line = split(/,/, $_);
        if($line[1] !~ /\d/){
            print "CSV file is not correct.\n";
            exit;
        }else{
            push(@CHR,$line[0]);
            if($line[1]>$max){
                $max=$line[1];
            }
        }
    }    
    close(IN);
    my @chr_return = ($max, \@CHR);
    return \@chr_return;
}

##############################################
# create bam
##############################################
sub _crtBam{
    my $BAM = shift;
    my $OUTDIR = shift;
    my $SAMTOOLS = shift;
    my $rt = shift;
    my @rt = @$rt;
    my $max= shift @rt;
    my $chr_sc = shift @rt;
    my @CHR= @$chr_sc;
    
    if(!-e "$OUTDIR"){
        mkdir("$OUTDIR") or die "$!: $OUTDIR";
    } else{
        print "$OUTDIR already exists.\n";
        exit(0);
    }
    my $rg_chr ="'";
    $rg_chr=$rg_chr.join("' '", @CHR);
    $rg_chr=$rg_chr."'";
    my $temp_bam=$OUTDIR."/tasuke_temp.bam";
    my $cmd=$SAMTOOLS." view -bh ".$BAM." ".$rg_chr." > ".$OUTDIR."/tasuke_temp_us.bam";
    my $sort = $SAMTOOLS." sort -m 2G ".$OUTDIR."/tasuke_temp_us.bam > ".$OUTDIR."/tasuke_temp.bam ";
    my $index = $SAMTOOLS." index ".$OUTDIR."/tasuke_temp.bam";
    # print($sort."\n");
    if (system($cmd)){
        print  "samtools view failed.\n Exit.\n";
        exit;
    }
    if (system($sort)){
        print  "samtools sort failed.\n Exit.\n";
        exit;
    }
    unlink $OUTDIR."/tasuke_temp_us.bam";
    if (system($index)){
        print  "samtools index failed.\n Exit.\n";
        exit;
    }
    return $temp_bam;
}

###########################################################
# samtools depth
###########################################################
sub _createDepth{
    my $BAM = shift;
    my $OUTDIR = shift;
    my $SAMTOOLS = shift;
    my $rt = shift;
    my $opt=shift;
    my @rt = @$rt;
    my $max= shift @rt;
    my $chr_sc = shift @rt;
    my $bamname = shift;
    my $OUTFILE = shift;
    my @CHR= @$chr_sc;
    my @CHR_files;
    my @CHR_header;
    my @CHR_DEL;
    my $num_reads=0;
    my $CD = Cwd::getcwd();
    
    my $cmd_stat=$SAMTOOLS." idxstats ".$BAM." |";
    open(CMDSTAT, $cmd_stat);
    while (<CMDSTAT>) {
        chomp;
        my @line = split(/\t/, $_);
        $num_reads+=$line[2];
    }
    close(CMDSTAT);
    if($num_reads < 1){
        $num_reads=1;
    }
    my $cmd=$SAMTOOLS.' depth '.$opt.' '.$BAM.' | awk '."\'".'BEGIN { prev_chr="";prev_pos=0; max='.$max.'; file=""; file_k=""; sum=0; posfile="'.$OUTDIR.'/""postion";  if((max % 1000) == 0 ){ file_k_count=(max/1000)+1;} else { file_k_count=(max/1000)+1;} } { if (NR == 1) { {file="'.$OUTDIR.'/"$1; file_k="'.$OUTDIR.'/"$1"_K";} for(i=1;i<int($2);++i) {printf("%s\n","\\\\N") > file; if(i % 1000 == 0){ if(sum==0){printf("%s\n","\\\\N") > file_k; sum=0;} else { printf("%d\n",(sum/1000)) > file_k; sum=0;}} }} if (int($2) > max && $1 == prev_chr){  next;}   else if($1 != prev_chr && $2 != max){  for(i=prev_pos+1;i<=int(max);++i) {printf("%s\n","\\\\N") > file ; if(i % 1000 == 0){ if(sum==0){printf("%s\n","\\\\N") > file_k; sum=0;} else { printf("%d\n",(sum/1000)) > file_k; sum=0;}}} {if(sum==0){printf("%s\n","\\\\N") > file_k; sum=0;} else { printf("%d\n",(sum/1000)) > file_k; sum=0;}} {for(i=file_k_count;i<=int(max);++i) {printf("%s\n","\\\\N") > file_k; sum=0;}} {close(file); file="'.$OUTDIR.'/"$1; close(file_k); file_k="'.$OUTDIR.'/"$1"_K"; }  for(i=1;i<int($2);++i) {printf("%s\n","\\\\N") > file;  if(i % 1000 == 0){ if(sum==0){printf("%s\n","\\\\N") > file_k; sum=0;} else { printf("%d\n",(sum/1000)) > file_k; sum=0;}}} } else if($1==prev_chr && prev_pos+1!=int($2))  {for(i=prev_pos+1;i<int($2);++i) {printf("%s\n","\\\\N") > file;  if(i % 1000 == 0){ if(sum==0){printf("%s\n","\\\\N") > file_k; sum=0;} else { printf("%d\n",(sum/1000)) > file_k; sum=0;}}}}  {printf("%d\n",$3) > file;} {sum=sum+$3; if($2 % 1000 == 0){if(sum==0){printf("%s\n","\\\\N") > file_k; sum=0;} else {printf("%d\n",(sum/1000)) > file_k; sum=0;}} } prev_chr=$1;prev_pos=int($2);}     END { {if(sum==0){printf("%s\n","\\\\N") > file_k; sum=0;} else {printf("%d\n",(sum/1000)) > file_k; sum=0;}}  for(i=prev_pos+1;i<=int(max);++i) {printf("%s\n","\\\\N") > file;  if(i % 1000 == 0){ if(sum==0){printf("%s\n","\\\\N") > file_k; sum=0;} else { printf("%d\n",(sum/1000)) > file_k; sum=0;}}}   for(i=file_k_count;i<=int(max);++i) {printf("%s\n","\\\\N") > file_k;}   for(i=1;i<=int(max);++i) {printf("%d\n",i) > posfile; } } '."\'";
    push(@CHR_header, "#postion#reads=".$num_reads);
    foreach my $x(@CHR){
        push(@CHR_files, $OUTDIR."/".$x);
        push(@CHR_files, $OUTDIR."/".$x."_K");
        push(@CHR_header, $x);
        push(@CHR_header, $x."_K");
        push(@CHR_DEL, $x);
        push(@CHR_DEL, $x."_K");
    }
    my $param1= join(" ", @CHR_files);
    my $param2 = $OUTDIR."/".basename($bamname).".depth_tmp";
    my $param3 = $OUTDIR."/".basename($bamname).".depth";
    my $param4= join("\t", @CHR_header);
    push(@CHR_DEL, "postion");
    push(@CHR_DEL, "header");
    push(@CHR_DEL, basename($bamname).".depth_tmp");
    if (system($cmd)){
        print  "samtools depth failed.\n Exit.\n";
        exit;
    }
    unlink $OUTDIR."/tasuke_temp.bam";
    unlink $OUTDIR."/tasuke_temp.bam.bai";
    
    opendir(DIRHANDLE, $OUTDIR."/");
    my @files = readdir(DIRHANDLE);
    closedir(DIRHANDLE);
    foreach my $x(@CHR){
        my $create_new = 0;
        foreach(@files){
            if($_ =~ /^$x$/){$create_new=1;}    
        }
        if($create_new==0){
            open OUT, '>', $OUTDIR."/".$x or die "file open error: $!";
            open OUT_K, '>', $OUTDIR."/".$x."_K" or die "file open error: $!";
            for(my $d=1; $d< $max+1; $d++){
                print OUT "\\N\n";
            }
            for(my $e=1; $e< $max+1; $e++){
                print OUT_K "\\N\n";
            }
            close(OUT);
            close(OUT_K);
        }
    }
    my $cmd2 = "paste ".$OUTDIR."/postion $param1 > $param2";
    $cmd2= sprintf("%s", $cmd2);
    if (system($cmd2)){
        print  "Error: merge depth file.\n";
        exit;
    }
    my $cmd3="echo \"".$param4."\" > ".$OUTDIR."/header";
    $cmd3= sprintf("%s", $cmd3);
    if (system($cmd3)){
        print  "Error: creating header file.\n ";
        exit;
    }
    my $cmd4="cat ".$OUTDIR."/header ".$param2." | head -n  ".($max+1)." > ".$param3;
    $cmd4= sprintf("%s", $cmd4);
    if (system($cmd4)){
        print  "Error: creating depth file.\n ";
        exit;
    }
    
    my $result = basename($bamname).".depth";
    move($OUTDIR."/".$result, $CD."/".$OUTFILE);
    clean_dir($OUTDIR, \@CHR_DEL, $CD);
    rmdir($OUTDIR);
}

#### print usage #######################################
sub _print_time {
    my ($str) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    $year += 1900;
    $mon += 1;
    my $datetime = sprintf "%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec;
    
    print "$str : $datetime\n";
}

### Removing temp files #################################
sub clean_dir{
    my $work_dir = shift;
    my $chr_sc = shift;
    my $CD = shift;
    my @files= @$chr_sc;
    
    chdir("$work_dir") or die "$! : $work_dir";
    foreach my $file(@files){    
        if(-e $file ){
            unlink $file;
        }
    }
    chdir($CD) or die "$! : $CD";
}

#### print usage #######################################
sub _error_method {
    print "\nConvert BAM file to the TSV formatted depth file\n\n";
    print "tasuke_bamtodepth.pl -s [samtools_path] -c [chromosome_information] -i [bam_file] -o[output_file]  \n\n";
    print "Options : \n";
    print "-bq [base quality threshold]\n";
    print "-mq [mapping quality threshold]\n\n";
}

