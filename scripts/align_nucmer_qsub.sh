mkdir -p nucmer

for f in ../genomes/*.fna
do 
	name=$(basename $f .fna)
	echo $name
	nucmer -p $name  ../ref/reference.fasta $f; show-coords -d -T -H $name.delta -L 500 > nucmer/$name.coords; rm $name.delta
done



## 2do
# select reference automaticly if no refence is defined. Largerst and finilized as cirteria
