#!/usr/bin/perl

use strict;
use warnings;

use v5.14;

use Bio::SeqIO;
use Bio::SeqUtils;

use Getopt::Long;

my $punto;

sub help
{
   my $msg = shift;
   
   print "$msg\n\n"
      if $msg;
   
   print <<STOP;
$0 [...] <Archivo 1, Archivo 2, ...>
Trabajo Práctico Final Bioinformática 2C 2015

   --punto, -p
      Selecciona el modo de ejecución, correpondiente al punto del TP:
      
        1: Conversion de secuencias de nucleótidos GenBank a FASTA en todos los marcos
           de lectura posibles.
           
           Ejemplo: $0 --punto 1 data/HBB_mRNA.gb
   
   --help, --ayuda, -?, -h
      Muestra este mensaje.
STOP

   exit 1;
}

GetOptions(
   'punto|p=s'       => \$punto,
   'help|ayuda|h|?'  => \&help,
) or help;


sub punto1
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

# Entry point
{
   help("Modo de operación (punto) no especificado.")
      unless $punto;
   
   help("Ningún archivo especificado")
      unless @ARGV;

   if ($punto == 1) {
      punto1 (@ARGV);
   } else {
      help("Punto $punto desconocido.");
   }
}

