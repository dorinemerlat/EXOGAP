rule repeat_modeler:
    input:
        check = rules.check_all_config.output.all,
        genome = rules.reformat_genome.output.reformated_genome
    output:
        repeats = "resources/repeats/{specie}_repeats_all.fa"
    params:
        path_repeatmodeler = find_environnement('repeatmodeler')
    log: 
        "logs/repeatModeler/{specie}.log"
    threads: 
        20
    conda:
        get_conda("repeatmodeler")
    shell:
        """
        exogap=$(pwd)
        mkdir results/{wildcards.specie}
        cd results/{wildcards.specie}
        mkdir repeat_modeler
        cd repeat_modeler

        bin_dir=$exogap/{params.path_repeatmodeler}/bin

        BuildDatabase -name {wildcards.specie} -engine ncbi $exogap/{input.genome}
        # RepeatModeler -pa {threads} -engine ncbi -database {wildcards.specie} -LTRStruct 2>&1
        RepeatModeler -pa {threads} -engine ncbi -database {wildcards.specie} -LTRStruct \
            -ninja_dir $bin_dir 2>&1
        ln -s $(pwd)/{wildcards.specie}-families.fa $exogap/{output.repeats}
        """

if config['repeats']['use_all_species'] == False:
    rule make_repeats_sets:
        input:
            all_repeats = "resources/repeats/{specie}_repeats_all.fa"
        output:
            known = "resources/repeats/{specie}_repeats_knowns.fa",
            unknown = "resources/repeats/{specie}_repeats_unknowns.fa"
        log: 
            "logs/make_repeats_sets/{specie}.log"
        conda:
            get_conda("toolbox")
        shell:
            """
            exogap=$(pwd)
            if [ ! -d results/{wildcards.specie}/split_repeats ]; then
                mkdir results/{wildcards.specie}/split_repeats
            fi

            cd results/{wildcards.specie}/split_repeats

            $exogap/workflow/scripts/rename_repeats.py -i $exogap/{input.all_repeats} \
                -o {wildcards.specie}_repeats_rename.fa -p {wildcards.specie}

            $exogap/workflow/scripts/sorting_repeats.py -i {wildcards.specie}_repeats_rename.fa \
                -k {wildcards.specie}_repeats_knowns.fa -u {wildcards.specie}_repeats_unknowns.fa

            ln -s $(pwd)/{wildcards.specie}_repeats_knowns.fa $exogap/{output.known}
            ln -s $(pwd)/{wildcards.specie}_repeats_knowns.fa $exogap/{output.unknown}
            """


    rule repeat_masker:
        input:
            genome = "resources/genomes/{specie}_genome.fa",
            known = "resources/repeats/{specie}_repeats_knowns.fa",
            unknown = "resources/repeats/{specie}_repeats_unknowns.fa",
            repbase = "resources/repeats/RepBase_arthropoda.fa"
        output:
            masked_genome = "results/{specie}/repeat_masker/final_mask/{specie}_finalMask.fa",
            repeats_gff = "results/{specie}/repeat_masker/final_mask/{specie}_finalMask_complex_reformat.gff3",
            repeats_tbl = "results/{specie}/repeat_masker/final_mask/{specie}_finalMask.tbl"
        params: 
            repeat_maker_dir = directory("results/{specie}/repeat_masker")
        log: 
            "logs/repeat_masker/{specie}.log"
        conda:
            get_conda("annotation")
        threads: 
            20
        shell:
            """
            workflow/scripts/run_repeats_basic.sh -f $(pwd)/{input.genome} -o $(pwd)/{params.repeat_maker_dir} \
                -c {threads} -s {wildcards.specie} -k $(pwd)/{input.known} -u $(pwd)/{input.unknown} -r $(pwd)/{input.repbase}
            """

else:
    rule make_one_lib:
        input:
            library_by_specie = expand("resources/repeats/{specie}_repeats_all.fa", specie = SPECIES)
        output:
            big_library = "resources/repeats/{set}_repeats_all.all"
        log: 
            "logs/make_one_lib/{set}.log"
        conda:
            get_conda("toolbox")
        shell:
            'cat {input.library_by_specie} > {output.big_library}'        

    rule make_repeats_sets:
        input:
            all_repeats = "resources/repeats/{set}_repeats_all.all"
        output:
            known = "resources/repeats/{set}_repeats_knowns.fa",
            unknown = "resources/repeats/{set}_repeats_unknowns.fa"
        log: 
            "logs/make_repeats_sets/{set}.log"
        conda:
            get_conda("toolbox")
        shell:
            """
            exogap=$(pwd)
            if [ ! -d results/repeats/split_repeats ]; then
                mkdir results/repeats/split_repeats
            fi

            cd results/repeats/split_repeats

            $exogap/workflow/scripts/rename_repeats.py -i $exogap/{input.all_repeats} \
                -o repeats_repeats_rename.fa -p repeats

            $exogap/workflow/scripts/sorting_repeats.py -i repeats_repeats_rename.fa \
                -k repeats_repeats_knowns.fa -u repeats_repeats_unknowns.fa

            ln -s $(pwd)/repeats_repeats_knowns.fa $exogap/{output.known}
            ln -s $(pwd)/repeats_repeats_knowns.fa $exogap/{output.unknown}
            """


    rule repeat_masker:
        input:
            genome = "resources/genomes/{specie}_genome.fa",
            known = expand("resources/repeats/{set}_repeats_knowns.fa", set = config['repeats']['use_all_species']),  
            unknown = expand("resources/repeats/{set}_repeats_unknowns.fa", set = config['repeats']['use_all_species']),
            repbase = "resources/repeats/RepBase_arthropoda.fa"
        output:
            masked_genome = "results/{specie}/repeat_masker/final_mask/{specie}_finalMask.fa",
            repeats_gff = "results/{specie}/repeat_masker/final_mask/{specie}_finalMask_complex_reformat.gff3",
            repeats_tbl = "results/{specie}/repeat_masker/final_mask/{specie}_finalMask.tbl"
        params: 
            repeat_maker_dir = directory("results/{specie}/repeat_masker")
        log: 
            "logs/repeat_masker/{specie}.log"
        conda:
            get_conda("annotation")
        threads: 
            20
        shell:
            """
            workflow/scripts/run_repeats_basic.sh -f $(pwd)/{input.genome} -o $(pwd)/{params.repeat_maker_dir} \
                -c {threads} -s {wildcards.specie} -k $(pwd)/{input.known} -u $(pwd)/{input.unknown} -r $(pwd)/{input.repbase}
            """


# rule make_repeats_sets:
#     input:
#         all_repeats = "resources/repeats/{set}_repeats_all.fa"
#     output:
#         known = "resources/repeats/{set}_repeats_knowns.fa",
#         unknown = "resources/repeats/{set}_repeats_unknowns.fa"
#     log: 
#         "logs/make_repeats_sets/{set}.log"
#     conda:
#         get_conda("toolbox")
#     shell:
#         """
#         exogap=$(pwd)
#         if [ ! -d results/{wildcards.specie}/split_repeats ]; then
#             mkdir results/{wildcards.specie}/split_repeats
#         fi

#         cd results/{wildcards.specie}/split_repeats

#         $exogap/workflow/scripts/rename_repeats.py -i $exogap/{input.all_repeats} \
#             -o {wildcards.specie}_repeats_rename.fa -p {wildcards.specie}

#         $exogap/workflow/scripts/sorting_repeats.py -i {wildcards.specie}_repeats_rename.fa \
#             -k {wildcards.specie}_repeats_knowns.fa -u {wildcards.specie}_repeats_unknowns.fa

#         ln -s $(pwd)/{wildcards.specie}_repeats_knowns.fa $exogap/{output.known}
#         ln -s $(pwd)/{wildcards.specie}_repeats_knowns.fa $exogap/{output.unknown}
#         """


# rule repeat_masker:
#     input:
#         genome = "resources/genomes/{specie}_genome.fa",
#         known = expand("resources/repeats/{set}_repeats_knowns.fa", set = repeats_set),
#         unknown = expand("resources/repeats/{set}_repeats_unknowns.fa", set = repeats_set),
#         repbase = "resources/repeats/RepBase_arthropoda.fa"
#     output:
#         masked_genome = "results/{specie}/repeat_masker/final_mask/{specie}_finalMask.fa",
#         repeats_gff = "results/{specie}/repeat_masker/final_mask/{specie}_finalMask_complex_reformat.gff3",
#         repeats_tbl = "results/{specie}/repeat_masker/final_mask/{specie}_finalMask.tbl"
#     params: 
#         repeat_maker_dir = directory("results/{specie}/repeat_masker")
#     log: 
#         "logs/repeat_masker/{specie}.log"
#     conda:
#         get_conda("annotation")
#     threads: 
#         20
#     shell:
#         """
#         workflow/scripts/run_repeats_basic.sh -f $(pwd)/{input.genome} -o $(pwd)/{params.repeat_maker_dir} \
#             -c {threads} -s {wildcards.specie} -k $(pwd)/{input.known} -u $(pwd)/{input.unknown} -r $(pwd)/{input.repbase}
#         """
