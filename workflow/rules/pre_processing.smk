rule reformat_genome:
    input:
        genome = "resources/genomes/{specie}_genome.fa"
    output:
        reformated_genome = "resources/genomes/{specie}_genome_rename.fa"
    log:
        "logs/reformat_genome/{specie}.log"
    threads:
        1
    conda:
        "envs/toolblox.yaml"
    shell:
        "workflow/scripts/reformat_genome.py -i {input.genome}"

rule evaluate_genome:
    input:
        genome = rules.reformat_genome.output.reformated_genome
    output:
        busco_stats = "results/{specie}/busco_assembly/{specie}/{specie}.txt"
    params:
        library = config['lib_busco'],
        busco_base = "{specie}"
    log:
        "logs/evaluate_genome/{specie}.log"
    conda:
        "../envs/toolbox.yaml"
    threads:
        64
    shell: 
        """
        cd results/{wildcards.specie}
        busco -i ../../{input.genome} -l {params.library} -o {params.busco_base} -m geno -c {threads} --long -f
        
        cd {params.busco_base}
        rename -v "s/short_summary.specific.{params.library}.{wildcards.specie}/{wildcards.specie}/" short_summary*
        """
