mkdir -p ogs_al


for f in ogs/*.fasta
do
        name=$(basename $f .fasta)
        ./muscle -in ogs/$name.fasta -out ogs_al/$name.fasta -quiet
        printf "."
done
