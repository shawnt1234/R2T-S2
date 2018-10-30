#!/usr/bin/perl
use strict;
use Cwd;
#Karolina Heyduk - heyduk@uga.edu - 2014

#this script will run CAP3 on all fasta files ending with a certain ending. CHANGE THE GLOB function at the beginning of this script
#to reflect what your RSEM filtered fasta files end with. This script by default looks for _ as the divider between the libID and the
#rest of the name. If your fastas are just named libID.fasta, then change my $divider = "_" to "." This will output all the cap3 files
#into the current directory. You can move them all at once with mv *cap3.* or whatever.
my $match = $ARGV[0]; #%match you want
my $list = $ARGV[1]; #list of library IDs
my $dir = $ARGV[2]; #full path to Trinity directory
my $wd = getcwd;
my @ids;

open IN, "<$list";
while (<IN>) {
	chomp;
	my $line = $_;
	push (@ids, $line);
	}

foreach my $id (@ids) {
	chdir("$dir/$id");
	open OUT, ">>$id.cap3.sh";
	print OUT "#!/bin/bash
#PBS -q batch
#PBS -N $id.cap3
#PBS -l nodes=1:ppn=1:AMD
#PBS -l walltime=480:00:00
#PBS -l mem=20gb

#PBS -M shawnt\@uga.edu
#PBS -m ae

cd \$PBS_O_WORKDIR

module load CAP3/03092015
cap3 contigs.fasta -x $id -p $match";
	close OUT;
	system "qsub $id.cap3.sh";
	chdir("$wd")
	}
