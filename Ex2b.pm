package Ex2b;

use Bio::Tools::Run::Alignment::Clustalw;

sub run
{
	foreach my $file_in (@_)
	{
		$factory = Bio::Tools::Run::Alignment::Clustalw->new(
				'ktuple' => 2,
				'matrix' => 'BLOSUM');

		($aln, $tree) = $factory->run($file_in);

		print "Longitud: ", $aln->length, "\n";

		print "Alineamiento:\n";
		foreach $seq ($aln->each_seq) {
			print $seq->seq(), "\n";
		}
	}
}

1;
