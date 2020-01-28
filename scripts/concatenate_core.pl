use Bio::SeqIO;

$dir = "../tmp/coreogaligns/"; 
opendir(DIR, $dir);
my @files = readdir DIR;

my %Sequences = ();

foreach $fn (@files)
{
	next until($fn =~ /\.fasta/);
	$inseq = Bio::SeqIO->new(-file => "$dir/$fn",  -format => "fasta");
	while($seq = $inseq->next_seq)
	{
		$strain = (split('\|',$seq->id()))[0];
		$Sequences {$strain} .= $seq->seq();
	}
}

$outfile = "../tmp/coreogaligned.fasta";

open O, ">$outfile";
foreach $strain(keys %Sequences)
{

	print O ">$strain\n";
	print O $Sequences {$strain} . "\n";
}
close O;


