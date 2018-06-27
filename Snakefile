configfile: 'config.yml'

GENOMES, = glob_wildcards("fna/{genome}.fasta")

localrules: all, nucmer_selectRef, make_path

rule all:
	input: 
		"paths.sif"

rule make_path:
	input:
		expand("tmp/nucmer/{qu}.coords", qu=GENOMES),
		"tmp/ortho_table.txt"
		
	output:
		"paths.sif"
	shell:
		"Rscript scripts/OG2graph.r"

rule nucmer:
	input:
		query="fna/{qu}.fasta",
		ref="tmp/ref/reference.fasta"
	output:
		"tmp/nucmer/{qu}.coords"
	shell:
		'''name=$(basename "{input.query}" .fasta);'''
		#"nucmer -p $name {input.ref} {input.query};"
		'''nucmer -p "$name" "{input.ref}" "{input.query}";'''
		'''show-coords -d -T -H "$name.delta" -L 500 > "tmp/nucmer/$name.coords";'''
		'''rm "$name.delta"'''

rule nucmer_selectRef:
	input:
		expand("fna/{qu}.fasta", qu=GENOMES)
	output:
		"tmp/ref/reference.fasta"
	shell:
		"mkdir -p tmp; mkdir -p tmp/ref; cp $(ls fna/*.fasta | head -1) tmp/ref/reference.fasta"

rule orthofinder:
	input: 
		expand("faa/{qu}.fasta", qu=GENOMES)
	output:
		"tmp/ortho_table.txt"
	threads: 20
	log: "log.txt"
	shell:
		"bash scripts/run_orthofinder.sh {config[orthofinder.bin]} {threads}"
rule prokka:
	input:
		ancient("fna/{qu}.fasta")
	output:
		"prokka/{qu}"
	threads: 4
	shell:
		"name=$(basename {input} .fasta);"
		"prokka --cpus {threads} --outdir {output} --force --prefix $name --locustag $name {input}"

rule make_faa:
	input:
		ancient("prokka/{qu}")
	output:
		"faa/{qu}.fasta"
	shell:
		"name=$(basename {input});"
		"GB2faa.pl {input}/$name.gbk > {output}"
