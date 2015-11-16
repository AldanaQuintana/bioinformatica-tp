package Ex2;

use Bio::Tools::Run::StandAloneBlastPlus;

sub run
{
   foreach my $file_in (@_)
   {
      # Cambiar la extension del archivo de salida
      (my $file_out = $file_in) =~ s/\.[^.]+$/_blastp.out/;

      my $fac;

      if ($remoto) {
         $fac = Bio::Tools::Run::StandAloneBlastPlus->new(
            -db_name  => 'swissprot',
            -remote   => 1,
         );
      } else {
         $fac = Bio::Tools::Run::StandAloneBlastPlus->new(
            -db_name  => 'swissprot',
            -db_data  => 'swissprot',
            -create   => 1,
         );
      }

      print "Ejecutando BLASTp ", ($remoto? 'remoto': 'local'),
            " para las secuencias de $file_in ...\n";

      $fac->blastp(
         -query   => $file_in,
         -outfile => $file_out,
      );
   }
}

1;
