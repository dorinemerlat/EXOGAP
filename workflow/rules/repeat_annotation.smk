rule repeat_modeler:
    input:
        genome = rules.reformat_genome.output.reformated_genome
    output:
        repeats = "results/repeat_modeler/{specie}-all_repeats.fa"
    log: 
        "logs/repeatModeler/{specie}.log"
    threads: 
        20
    conda:
        "../envs/annotation.yaml"
    shell:
        """
        cd results/RepeatModeler

        BuildDatabase -name {wildcards.specie} -engine ncbi {input.genome}
        RepeatModeler -pa 20 -engine ncbi -database {wildcards.specie} -LTRStruct 2>&1
        cp {wildcards.specie}-families.fa ../../{output.repeats}
        """


rule make_repeat_sets:
    input:
        all_repeats = rules.repeat_modeler.output.repeats
    output:
        known = "results/repeat_modeler/{specie}_repeats_knowns.fa",
        unknown = "results/repeat_modeler/{specie}_repeats_unknowns.fa"
    log: 
        "logs/make_repeat_sets/{specie}.log"
    conda:
        "envs/toolbox.yaml"
    shell:
        """
        cd 
        workflow/scripts/rename_repeats.py -i {input.all_repeats} \
            -o {wildcards.specie}_all_repeats.fa -p {wildcards.specie}

        workflow/scripts/rename_repeats.py -i {wildcards.specie}_all_repeats.fa \
            -k {output.known} -u {output.unknown}
        """


rule repeat_masker:
    input:
        genome = "resources/genomes/{specie}_genome.fa",
        known = rules.make_repeat_sets.output.known,
        unknown = rules.make_repeat_sets.output.unknown,
        repbase = "resources/RepBase_arthropoda.fa"
    output:
        masked_genome = "results/repeat_masker/final_mask/{specie}_finalMask.fa",
        repeats_gff = "results/repeat_masker/final_mask/{specie}_finalMask_complex_reformat.gff3",
        repeats_tbl = "results/repeat_masker/final_mask/{specie}_finalMask.tbl"
    params: 
        repeat_maker_dir = directory("results/repeat_masker")
    log: 
        "logs/repeat_masker/{specie}.log"
    conda:
        "envs/annotation.yaml"
    threads: 
        20
    shell:
        """
        scripts/run_repeats_basic.sh -f {input.genome} -o {params.repeat_maker_dir} \
            -c {threads} -s {wildcards.specie} -k {input.known} -u {input.unknown} -r {input.repbase}
        """

