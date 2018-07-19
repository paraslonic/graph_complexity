calc(){ awk "BEGIN { print int($*) }"; }
ASM_FILE="$2"
COMPLETE_GENOMES=$(grep "$1" $ASM_FILE | grep "Complete" | wc -l)
ALL_GENOMES=$(grep "$1" $ASM_FILE | wc -l)
echo -e "GENOMES. All: $ALL_GENOMES\tComplete:$COMPLETE_GENOMES"
if [ $COMPLETE_GENOMES -ge 50 ]
then
	echo "will download only complete genomes"
	wget `grep "$1" $ASM_FILE | grep "Complete" | awk -F "\t" '{print $20}' | awk 'BEGIN{FS=OFS="/";filesuffix="genomic.fna.gz"}{ftpdir=$0;asm=$10;file=asm"_"filesuffix;print ftpdir,file}'`
else
	if [ $ALL_GENOMES -le 100  ]
	then
		echo "will download all genomes"
		wget `grep "$1" $ASM_FILE | awk -F "\t" '{print $20}' | awk 'BEGIN{FS=OFS="/";filesuffix="genomic.fna.gz"}{ftpdir=$0;asm=$10;file=asm"_"filesuffix;print ftpdir,file}'`
	else
		echo "will download random subset of genomes"
		grep "$1" $ASM_FILE | grep -v "Complete" | awk -F "\t" '{print $20}' | awk 'BEGIN{FS=OFS="/";filesuffix="genomic.fna.gz"}{ftpdir=$0;asm=$10;file=asm"_"filesuffix;print ftpdir,file}' > ncomplete_genomes.url
		shuf -n $(calc 100 - $COMPLETE_GENOMES) ncomplete_genomes.url > selected_genomes.url
		grep "$1" $ASM_FILE | grep "Complete" | awk -F "\t" '{print $20}' | awk 'BEGIN{FS=OFS="/";filesuffix="genomic.fna.gz"}{ftpdir=$0;asm=$10;file=asm"_"filesuffix;print ftpdir,file}' >> selected_genomes.url
		wget $(cat selected_genomes.url )
	fi
fi


echo $1
gunzip *.gz
mkdir -p fna
mv *.fna fna


