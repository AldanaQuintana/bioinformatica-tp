package Ex4;

use Bio::Factory::EMBOSS;
use Bio::SearchIO;

sub run
{
	foreach my $input (@_)
	{

		my $factory = new Bio::Factory::EMBOSS;
		my $app = $factory->program("getorf");
		my %param = ( -sequence => $input, -outseq => "data/orfs.out");

		print "Cargando ORFs y generando archivo de salida ORFS.out\n";
		$app->run(\%param);

		$app = $factory->program("patmatmotifs");
		%param = ( -sequence => $input, -full => "Y", -outfile => "data/dominios.out");
		print "Cargando motivos y generando archivo de salida dominios.out\n";
		$app->run(\%param);

	}
}

1;
