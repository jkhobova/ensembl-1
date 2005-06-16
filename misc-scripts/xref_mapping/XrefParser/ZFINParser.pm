package XrefParser::ZFINParser;

use strict;
use POSIX qw(strftime);
use File::Basename;

use XrefParser::BaseParser;

use vars qw(@ISA);
@ISA = qw(XrefParser::BaseParser);



# --------------------------------------------------------------------------------
# Parse command line and run if being run directly

if (!defined(caller())) {

  if (scalar(@ARGV) != 1) {
    print "\nUsage: ZFINParser.pm file <source_id> <species_id>\n\n";
    exit(1);
  }

  run($ARGV[0]);

}

sub run {

  my $self = shift if (defined(caller(1)));
  my $file = shift;
  my $source_id = shift;
  my $species_id = shift;

  if(!defined($source_id)){
    $source_id = XrefParser::BaseParser->get_source_id_for_filename($file);
  }
  if(!defined($species_id)){
    $species_id = XrefParser::BaseParser->get_species_id_for_filename($file);
  }

  my $dir = dirname($file);
  

  my (%swiss) = %{XrefParser::BaseParser->get_valid_codes("uniprot",$species_id)};
  my (%refseq) = %{XrefParser::BaseParser->get_valid_codes("refseq",$species_id)};

  open(SWISSPROT,"<".$dir."/swissprot.txt") || die "Could not open $dir/swissprot.txt\n";
#e.g.
#ZDB-GENE-000112-30      couptf2 O42532
#ZDB-GENE-000112-32      couptf3 O42533
#ZDB-GENE-000112-34      couptf4 O42534


  my $count =0;
  my $mismatch=0;
  while (<SWISSPROT>) {
    chomp;
    my ($zfin, $label, $acc) = split (/\s+/,$_);
    if(defined($swiss{$acc})){
      XrefParser::BaseParser->add_to_xrefs($swiss{$acc},$zfin,'',$label,'','',$source_id,$species_id);
      $count++;
    }
    else{
      $mismatch++;
    }
  }
  close SWISSPROT;
  
  open(REFSEQ,"<".$dir."/refseq.txt") || die "Could not open $dir/refseq.txt\n";
#ZDB-GENE-000125-12      igfbp2  NM_131458
#ZDB-GENE-000125-12      igfbp2  NP_571533
#ZDB-GENE-000125-4       dlc     NP_571019
  while (<REFSEQ>) {
    chomp;
    my ($zfin, $label, $acc) = split (/\s+/,$_);
    if(defined($refseq{$acc})){
      XrefParser::BaseParser->add_to_xrefs($refseq{$acc},$zfin,'',$label,'','',$source_id,$species_id);
      $count++;
    }
    else{
      $mismatch++;
    }
  }
  close REFSEQ;
  print "\t$count xrefs succesfully loaded\n";
  print "\t$mismatch xrefs ignored\n";
}

sub new {

  my $self = {};
  bless $self, "XrefParser::ZFINParser";
  return $self;

}
 
1;
