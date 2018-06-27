#!/usr/bin/perl 
use Data::Dumper;

$input = shift ;

exit if (! -s $input);

open F, "<$input";
open T, '>', "ortho_table.txt";
open O, '>', "ortho_table_names.txt";

%clust = ();
%strains = ();

while (my $f = <F>) {
	($clustid, @genes) = split (" ", $f);
	my %names = ();
	foreach $gene (@genes)
	{
		($strain, $id, $product) = split (/\|/, $gene);
		$clust{$clustid}{$strain}++;
		$clust{$clustid}{"${strain}_pname"} = $product;
		if(exists $clust{$clustid}{"${strain}_id"}) { $clust{$clustid}{"${strain}_id"} .= "," };
		$clust{$clustid}{"${strain}_id"} .= $gene;
		$names{$product}++;
		$strains{$strain} = 1;
	}
	#select name with maximum representatives
	$clust{$clustid}{"name"} = (reverse sort { $names{$a} <=> $names{$b} } keys %names)[0];
}

# make out
my @strains = keys %strains;
print T "id\tproduct\t" . join("\t", @strains). "\tstrains\n";		#header
print O "id\tproduct\t" . join("\t", @strains). "\n";		#header


foreach $clust ( keys %clust){
	print T "$clust\t" .  $clust{$clust}{"name"} . "\t";
	print O "$clust\t" .  $clust{$clust}{"name"} ;
	my $strain_string;
	my $strain_string_id;
	my $count = 0;
	for (@strains) {
 		$strain_string .= (exists $clust{$clust}{$_}? $clust{$clust}{$_} : 0) . "\t";
 		$strain_string_id .= "\t".(exists $clust{$clust}{$_}? $clust{$clust}{$_."_id"} : "");
 		$count += exists $clust{$clust}{$_}? 1 : 0;
	}
	print T "$strain_string$count\n";
	print O "$strain_string_id\n";
}
