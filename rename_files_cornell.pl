#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
my %pairs;
## for CORNELL RUNS
## rename file is different that UCR core

my $final_dir = $ARGV[0]; 
my $fq_dir = $ARGV[1];
my $rename_file = $ARGV[2];
## do a test run or the real thing 0=real thing, 1=test run
my $test = defined $ARGV[3] ? $ARGV[3] : 0; 
#my $test = 1;
if (!defined $fq_dir or !defined $final_dir or !defined $rename_file){
  die "perl rename_files.pl OUTPUT_DIR DIR_OF_FASTQ BARCODE_SAMPLE_FILE
example usage:
perl rename_files.pl /home_stajichlab/robb/Wessler-Rice/RIL/Illumina FC153_RIL_1_12 11122012.sample_adapter.list\n";
}
## head cornell.rename.file 
##2	6205_N_RILLib60-254_ACTTGA 	8	ACTTGA	237
##2	6205_N_RILLib60-254_ATCACG 	1	ATCACG	60

## diff from UCR core
my @files = <$fq_dir/*fastq>;

## no need for barcodes hash if i convert in the excel sheet, maybe next time, let the script conver
my %barcodes;
my %rename;
while (my $line = <DATA>){
  chomp $line;
  if ($line =~ /^\d/){
    my ($code,$adapter) = split /\s+/ , $line;
    print "($code,$adapter)\n" if $test;
    $barcodes{$code}=$adapter;
  }
}

print "opening $rename_file\n" if $test;
open (IDFILE, $rename_file) or die "Can't open $rename_file\n";
while (my $line = <IDFILE>){
  chomp $line;
  my ($lane,$sample,$code,$adaptor,$RIL) = split /\s+/ , $line;
  print "($lane,$sample,$code,$adaptor,$RIL)\n" if $test;
  #my $adapter = $barcodes{$code};
  $rename{$sample}{RIL}=$RIL;
  $rename{$sample}{LANE}=$lane
}

print "getting ready to rename\n" if $test;
foreach my $file (@files){
  #flowcell153_lane5_pair1_ACTGAT.fastq 
  chomp $file;
  #my ($fc,$lane,$pair,$barcode) = $file =~ /.+flowcell(\d+)_lane(\d+)_pair(\d)_([ATGC]{6})\.fastq/;
  #6205_N_RILLib60-254_ACTTGA
  #1946_2368_6207_N_RILs95-270_TGACCA_R1.fastq
  #1946_2368_6207_N_RILs95-270_CCGTCC_R2.fastq
  #1945_2368_6206_N_RILLib8-247_28-247_GTGAAA_R1.fastq
  #1943_2368_6204_N_RILLib83-230_TTAGGC_R1.fastq
  my ($one,$two,$sample,$laneID,$lib,$barcode,$pair) = $file =~ /(\d+)_(\d+)_((\d+)_N_(.+)_([ATCG]{6}))_(R\d)\.fastq/;
  print "($one,$two,$sample,$laneID,$lib,$barcode,$pair)\n" if $test;
  if ($pair eq 'R1'){
    $pair = 1;
  }else {
    $pair = 2;
  }
  if (exists $rename{$sample}){
    my $strain = $rename{$sample}{RIL};
    my $lane = $rename{$sample}{LANE};
    my $mv_dir = "$final_dir/$strain";
    if (!-d $mv_dir){
      `mkdir $mv_dir` if !$test;
    }
    my $base = "RIL" . $strain . "_" . $barcode . "_FC082013"."L$lane" ;
    my $newfile=$base."_p$pair.fq" ;
    $pairs{$base}{$pair}="$mv_dir/$newfile";
    #print "$mv_dir/$newfile\n";
    if (!-e "$mv_dir/$newfile"){
    #if (1){
      `ln -s $file $newfile` if !$test;
      #`rm -f $mv_dir/$newfile` if !$test;
      `ln -s $file $mv_dir/$newfile` if !$test;
    }
  }
}
foreach my $strain (keys %pairs){
  my @toPrint;
  push @toPrint , $strain;
  my $p1 = exists $pairs{$strain}{1} ? $pairs{$strain}{1} : '';
  my $p2 = exists $pairs{$strain}{2} ? $pairs{$strain}{2} : '';
  if (defined $p1){
    push @toPrint , $p1; 
  }
  if (defined $p2){
    push @toPrint , $p2;
  }
  print join (",",@toPrint) , "\n";
}
## IDs of Illumina barcodes
__DATA__
1	ATCACG
2	CGATGT
3	TTAGGC
4	TGACCA
5	ACAGTG
6	GCCAAT
7	CAGATC
8	ACTTGA
9	GATCAG
10	TAGCTT
11	GGCTAC
12	CTTGTA
13	AGTCAA
14	AGTTCC
15	ATGTCA
16	CCGTCC
17	GTAGAG
18	GTCCGC
19	GTGAAA
20	GTGGCC
21	GTTTCG
22	CGTACG
23	GAGTGG
24	GGTAGC
25	ACTGAT
26	ATGAGC
27	ATTCCT
28	CAAAAG
29	CAACTA
30	CACCGG
31	CACGAT
32	CACTCA
33	CAGGCG
34	CATGGC
35	CATTTT
36	CCAACA
37	CGGAAT
38	CTAGCT
39	CTATAC
40	CTCAGA
41	GACGAC
42	TAATCG
43	TACAGC
44	TATAAT
45	TCATTC
46	TCCCGA
47	TCGAAG
48	TCGGCA
