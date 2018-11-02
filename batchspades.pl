#!/usr/bin/perl
use strict;
use Cwd;
use Data::Dumper;
#Shawn Thomas - shawnt@uga.edu - 2018
#modified from script by Karolina Heyduk

my $dir = $ARGV[0]; #FULL PATH to spades folder, include final "/"
my $reads = $ARGV[1]; #FULL PATH to clean reads directory
my $CPU = $ARGV[2];
my $list = $ARGV[3]; #list of libIDs, should be the prefix of trimmomatic outputs
my @files = glob("*fastq"); #push files with correct ending into an array
my %control;
my $wd = getcwd;

#read library index file, store in hash
my %paired1;
my %paired2;
my %unpaired1;
my %unpaired2;
my @libIDs;
open IN, "<$list";
while (<IN>) {
	chomp;
	push (@libIDs, $_);
#	my ($libID, $readID) = split /\t/;
#	if ($readID =~ 'R1') { 
#		if ($readID =~ 'paired') {
#			$paired1{$libID} = $readID;
#			}
#		else {
#			$unpaired1{$libID} = $readID;
#			}
#		if ($libID ~~ @libIDs) {
#			next;
#			}
#		else {
#			push(@libIDs, $libID);
#			}
#		}
#	elsif ($readID =~ 'R2') {
#		if ($readID =~ 'paired') {
#			$paired2{$libID} = $readID;
#			}
#		else {
#			$unpaired2{$libID} = $readID;
#		}
#	}
	}
close IN;
print "@libIDs\n";

#make trinity folders and submission scripts
for my $libID (@libIDs) {       
        system "mkdir $dir$libID"; 
		chdir("$dir/$libID");
		open OUT, ">$libID.spades.sh"; #make a shell file for trinity submission
        print OUT "
#PBS -S /bin/bash
#PBS -N $libID\_SPAdes
#PBS -q batch
#PBS -l nodes=1:ppn=$CPU
#PBS -l walltime=100:00:00
#PBS -l mem=60gb  

cd \$PBS_O_WORKDIR
ml spades/3.12.0-k_245

python /usr/local/apps/gb/spades/3.12.0-k_245/bin/spades.py -1 $reads/$libID\_R1_P.fastq -2 $reads/$libID\_R2_P.fastq --only-assembler  --threads $CPU --memory 60  -o $dir$libID";
        system "qsub ./$libID.spades.sh";
		chdir("$wd");
		close OUT;
        }
