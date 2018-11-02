#! /usr/bin/perl

#Shawn Thomas - shawnt@uga.edu - 2018
#modified from script by Karolina Heyduk

use strict;
use warnings;
use Bio::SeqIO;
use Cwd;

my $dir = $ARGV[0]; #path to your Trinity directory (include /trinity/)
my @ids;
my @blastfiles = glob("*.top");
my $wd = getcwd;

#get list of IDs from the blastout files
foreach my $blastfile (@blastfiles) {
	my $divider = "_";
	my $position = index($blastfile, $divider);
	my $id = substr($blastfile, 0, $position);
	push (@ids, $id);
	}

#now look through all the libraries to pull out matches and rename them
foreach my $id (@ids) {
	my %seqs;
	chdir("$dir/$id");
	my $fasta = "contigs.fasta.$id.cap3";
	my $io_obj = Bio::SeqIO->new(-file => $fasta, -format => 'fasta');
	while (my $seqobj = $io_obj -> next_seq) {
		my $id = $seqobj -> id();
		my $seq = $seqobj -> seq();
		$seqs{$id}=$seq;
	}
	chdir("$wd");
	
open OUT, ">$id.targets.fasta";
open BLAST, "<$id\_target.out.top"; #assumes you have not deviated from the previous scripts (BLAST, gethits)
while (<BLAST>) {
	chomp;    
	my ($qid, $sid, undef, undef, undef, undef, $qstart, $qend, $sstart, $send, undef, undef) = split /\s+/;
        if (($send<$sstart)&&($qstart<$qend)){ 
#		print "is reversed\n";
		my $nseq=reverse($seqs{$qid});
#		print "\n$nseq\n";
		$nseq=~tr/ACTGactg/TGACtgac/;
#		print "\n$nseq\n";
		 print OUT ">$sid\n$nseq\n";
	}
	elsif (($sstart<$send)&&($qend<$qstart)){
#		print "is reversed\n";
		my $nseq=reverse($seqs{$qid});
#		print "\n$nseq\n";
		$nseq=~tr/ACTGactg/TGACtgac/;
#		print "\n$nseq\n";
		print OUT ">$sid\n$nseq\n";
	}
	elsif (($send<$sstart)&&($qend<$qstart)){
               # print "is reversed\n";
                my $nseq=reverse($seqs{$qid});
                #print "\n$nseq\n";
                #$nseq=~tr/ACTGactg/TGACtgac/;
                #print "\n$nseq\n";
               #print OUT ">$sid\n$nseq\n";
				print OUT ">$sid\n$nseq\n";
		}
	else {
	print OUT ">$sid\n$seqs{$qid}\n";
    }
}
close BLAST;
close OUT;
}
