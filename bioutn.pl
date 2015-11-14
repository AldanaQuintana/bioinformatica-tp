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

        3: Parsea un output de blast (por ejemplo, el resultado del ejercicio 2)
           con un pattern como parámetro
           y da como resultado un archivo con la lista de los hits
           que encuentren una coincidencia con ese pattern.
           El pattern debe ser una palabra sin espacios.

           Ejemplo: $0 --punto 3 data/HBB_mRNA_aa_blastp.out Hemoglobin
           Listará todos los los hits (accession + descripción) que tengan al menos una coincidencia con "Hemoglobin"

	4: Usando EMBOSS dada una secuencia de nucleotidos en formato fasta calcula los ORFs, generando un output en data/ORFs.out.
	   Luego realiza el analisis de dominios de las secuencias de aminoacidos obtenidas, generando un output en data/Dominios.out.

	   Ejemplo: $0 --punto 4 data/HBB_RefSeq_mRNA.gb

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

use Bio::SearchIO;

sub punto3
{

  my ($file_location, $pattern) = @_;
  my $matcher = qr/$pattern/;

  (my $file_output_location = $file_location) =~ s/\.[^.]+$/_matching_hits.txt/;
  open(my $file_output, '>', $file_output_location);

  my $file = new Bio::SearchIO(-file => $file_location, -format => 'blast');

  while(my $result = $file->next_result){
    while(my $hit = $result->next_hit){
      my $hit_description = $hit->description;

      if($hit_description =~ $matcher){
        print $file_output $hit->name;
        print $file_output "\n";
        print $file_output $hit_description;
        print $file_output "\n\n";
      }
    }
  }

  close $file_output;
}

use Bio::Factory::EMBOSS;
use Bio::SearchIO;

sub punto4
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
   } elsif ($punto == 3){
      punto3(@ARGV)
   } elsif ($punto == 4){
      punto4(@ARGV)
   } else {
      help("Punto $punto desconocido.");
   }
}

