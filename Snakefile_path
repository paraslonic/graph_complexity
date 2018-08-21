configfile: 'config.yml'

GENOMES, = glob_wildcards("fna/{genome}.fna")

localrules: all, nucmer_selectRef, make_path

rule all:
	input: 
		"out_w10/stat_window_complexity_table_contig0.txt",
		"out_w20/stat_window_complexity_table_contig0.txt"

rule calc_complexity:
	input:  "graph/paths.sif"
	output:  
		"out_w10/stat_window_complexity_table_contig0.txt",
		"out_w20/stat_window_complexity_table_contig0.txt"
	shell:
		" ref=$(basename $(grep '>' fna/*.fna -c | sort -t':' -nk2 -s | head -1) | sed 's/\.f.\+//g') "
		" echo $ref > tmp/reference "
		" start_computing.py -i graph/paths.sif -o graph/out_w10 --reference_stamm $ref --window 10 --iterations 100 "
		" start_computing.py -i graph/paths.sif -o graph/out_w20 --reference_stamm $ref --window 20 --iterations 100 "

rule make_path:
	input:
		"tmp/ortho_table.txt"
	output:
		"graph/paths.sif"
	shell:
		" {config[python.bin]} {config[gcb.path]}/orthofiner_parse.py -i tmp/Orthogroups.txt -o graph/paths "

rule nucmer:
	input:
		query="fna/{qu}.fna",
		ref="tmp/ref/reference.fasta"
	output:
		"tmp/nucmer/{qu}.coords"
	shell:
		'''name=$(basename "{input.query}" .fna);'''
		#"nucmer -p $name {input.ref} {input.query};"
		'''nucmer -p "$name" "{input.ref}" "{input.query}";'''
		'''show-coords -d -T -H "$name.delta" -L 500 > "tmp/nucmer/$name.coords";'''
		'''rm "$name.delta"'''

rule nucmer_selectRef:
	input:
		expand("fna/{qu}.fna", qu=GENOMES)
	output:
		"tmp/ref/reference.fasta"
	shell:
		"mkdir -p tmp; mkdir -p tmp/ref; cp $(ls fna/*.fna | head -1) tmp/ref/reference.fasta"

rule orthofinder:
	input: 
		expand("faa/{qu}.fasta", qu=GENOMES)
	output:
		"tmp/ortho_table.txt"
	threads: 20
	log: "log_of.txt"
	shell:
		"bash scripts/run_orthofinder.sh {config[orthofinder.bin]} {threads} > {log}"
rule prokka:
	input:
		ancient("fna/{qu}.fna")
	output:
		"prokka/{qu}"
	threads: 4
	shell:
		"name=$(basename {input} .fna);"
		"prokka --cpus {threads} --outdir {output} --force --prefix $name --locustag $name {input}"

rule make_faa:
	input:
		ancient("prokka/{qu}")
	output:
		"faa/{qu}.fasta"
	shell:
		"name=$(basename {input});"
		"GB2faa.pl {input}/$name.gbk > {output}"
