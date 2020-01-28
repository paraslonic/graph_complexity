mkdir -p nucmer

for f in ../genomes/*.fna
do 
	name=$(basename $f .fna)
	echo $name
	echo "nucmer -p $name  ../ref/reference.fasta $f; show-coords -d -T -H $name.delta -L 500 > nucmer/$name.coords; rm $name.delta" | qsub -cwd 
done

