#!/usr/bin/perl

use strict;
use warnings;

use v5.14;

use Getopt::Long;

use Ex1;
use Ex2;
use Ex3;
use Ex4;

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

# Entry point
{
   help("Modo de operación (punto) no especificado.")
      unless $punto;

   help("Ningún archivo especificado")
      unless @ARGV;

   if ($punto == 1) {
      Ex1::run(@ARGV);
   } elsif ($punto == 2) {
      Ex2::run(@ARGV);
   } elsif ($punto == 3) {
      Ex3::run(@ARGV);
   } elsif ($punto == 4) {
      Ex4::run(@ARGV);
   } else {
      help("Punto $punto desconocido.");
   }
}

