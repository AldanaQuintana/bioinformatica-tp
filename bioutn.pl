#!/usr/bin/perl

use strict;
use warnings;

use v5.14;

use Bio::SeqIO;
use Bio::SeqUtils;
use Bio::Tools::Run::StandAloneBlastPlus;

use Getopt::Long;

# Opciones
my $punto;
my $remoto;

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
           
        2: BLAST+ sobre secuencias FASTA, local o remoto. Para realizar ejecuciones
           locales es necesario contar con la base swissprot descomprimida en
           db/swissprot (puede ser obtenida en la dirección
           ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/swissprot.gz). La creación de la
           base de datos para el algoritmo se realiza la primera vez que es usada de
           forma interna.
        
           Ejemplo de ejecución remota: $0 --punto 2 -r data/HBB_mRNA_aa.fas
           Ejemplo de ejecución local:  $0 --punto 2    data/HBB_mRNA_aa.fas
           
   --remoto, -r
      Usar algoritmos remotos cuando sea posible (ver punto 2).
   
   --help, --ayuda, -?, -h
      Muestra este mensaje.
STOP

   exit 1;
}

GetOptions(
   'punto|p=s'       => \$punto,
   'remoto|r'        => \$remoto,
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

sub punto2
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

# Entry point
{
   help("Modo de operación (punto) no especificado.")
      unless $punto;
   
   help("Ningún archivo especificado")
      unless @ARGV;

   if ($punto == 1) {
      punto1(@ARGV);
   } elsif ($punto == 2) {
      punto2(@ARGV);
   } else {
      help("Punto $punto desconocido.");
   }
}

