rule reformat_genome:
    input:
        genome = "resources/genomes/{specie}_genome.fa"
    output:
        reformated_genome = "resources/genomes/{specie}_genome_rename.fa"
    params:
        script_reformat = "workflow/scripts/reformat_genome.py"
    log:
        "logs/reformat_genome/{specie}.log"
    threads:
        1
    conda:
        get_conda("toolbox")
    shell:
        "{params.script_reformat} -i {input.genome}"


rule evaluate_genome:
    input:
        genome = rules.reformat_genome.output.reformated_genome
    output:
        busco_stats = "results/{specie}/busco/{specie}/{specie}.txt"
    params:
        library = config['lib_busco'],
        busco_base = "{specie}_assembly",
        busco_dir = "results/{specie}/busco_assembly/"
    log:
        "logs/evaluate_genome/{specie}.log"
    conda:
        get_conda("toolbox")
    threads:
        64
    shell: 
        """
        exogap=$(pwd)
        cd {params.busco_dir}
        busco -i $exogap/{input.genome} -l {params.library} -o {params.busco_base} -m geno -c {threads} --long -f
        
        cd {params.busco_base}
        rename -v "s/short_summary.specific.{params.library}.{params.busco_base}/{params.busco_base}/" short_summary*
        """