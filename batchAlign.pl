#!/usr/bin/perl
# take a set of multifasta files for each species and sort genes by ID into separate gene files
# run prank on each gene file
# Karolina Heyduk - heyduk@uga.edu - 2014
#modified from script by Alex Harkess

use strict;
use Bio::SeqIO;

my @infiles = glob("*.genes");
my %sorted_genes;

for my $infile (@infiles) {
    my $fileSeq = Bio::SeqIO -> new (-file => "$infile", -format => "fasta"); #this line calls bioperl and defines the infile as a bioperl variable
    while (my $io_obj = $fileSeq -> next_seq() ) {
	my $origHeader = $io_obj->id(); 
	my $divider = "_";
	my $position = rindex ($origHeader, $divider); # finds the last occurrence of "_" in the original header. If you used batchMakegenes.pl, your headers should be in the format of ">geneID_libID".
	my $geneID = substr($origHeader, 0, $position);
	my $species = substr($origHeader, $position + 1);
	
    my $seq = $io_obj->seq;
	$sorted_genes{$geneID}{$species} = $seq;
    }
}

for my $geneID (sort keys %sorted_genes) {
    open OUT, ">>", "$geneID.sorted.fa";
    for my $species (sort keys %{$sorted_genes{$geneID}}) {
	print OUT ">$species\n$sorted_genes{$geneID}{$species}\n";
    }
}
close OUT;

# run prank on all the gene groups
my @prealign = glob("*sorted.fa");
for my $prealign (@prealign) {
    open OUT, ">>$prealign.prank.sh";
	print OUT "
#PBS -S /bin/bash
#PBS -N $prealign\_prank
#PBS -q batch
#PBS -l nodes=1:ppn=1
#PBS -l walltime=100:00:00
#PBS -l mem=10gb

#PBS -M shawnt\@uga.edu
#PBS -m ae

cd \$PBS_O_WORKDIR

module load PRANK/170427-foss-2016b

prank -d=$prealign -DNA -o=$prealign.prank";
	close OUT;
	system "qsub $prealign.prank.sh";
}

