package Ex3;

use Bio::SearchIO;

sub run
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

1;
