package Ex1;

use Bio::SeqIO;
use Bio::SeqUtils;

sub run
{
   foreach my $file_in (@_)
   {
      # Cambiar la extension del archivo de salida
      (my $file_out = $file_in) =~ s/\.[^.]+$/_aa.fas/;

      # Leer archivo
      my $seqio_in = Bio::SeqIO->new(
         -file    => $file_in,
         -format  => 'genbank',
      );

      my $seqio_out = Bio::SeqIO->new(
         -file    => ">$file_out",
         -format  => 'fasta',
      );

      my $c = 0;

      # Por cada una de las secuencias contenidas, traducir los 6
      # frames y escribir a un nuevo archivo .fas
      while (my $seq = $seqio_in->next_seq)
      {
         $c++;

         my @aa = Bio::SeqUtils->translate_6frames($seq);

         foreach my $aa (@aa)
         {
            $seqio_out->write_seq($aa);
         }
      }

      print "Archivo $file_in: $c secuencias convertidas a $file_out\n";
   }
}

1;
