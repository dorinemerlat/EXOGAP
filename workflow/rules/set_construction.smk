import sys

rule construct_main_protein_set:
    output:
        protein_set = "resources/proteins/main/{main_protein}_protein_set_redundant.fa"
    params:
        large_taxid = lambda w: INFOS_MAIN_SET_PROTEIN["{}".format(w.main_protein)]['large_taxon_taxid'],
        small_taxid = lambda w: INFOS_MAIN_SET_PROTEIN["{}".format(w.main_protein)]['small_taxon_taxid']
    log:
        "logs/construct_main_protein_set/{main_protein}.log"
    # conda:
    #     "envs/toolbox.yaml"
    run:
        large_protein_set = request_api.get_reviewed_proteins_of_reference_proteome_from_taxon({params.large.taxid})
        small_protein_set = request_api.get_all_proteins_from_taxon({params.small_taxid})
        protein_set = large_protein_set + small_protein_set

        with open({output.protein_set}, 'w') as file:
            for i in protein_set:
                file.write(i)

rule construct_augustus_protein_set:
    output:
        protein_set = "resources/proteins/augustus/{augustus_protein}_protein_set_redundant.fa"
    params:
        taxid = lambda w: INFOS_MAIN_SET_PROTEIN["{}".format(w.augustus_protein)]['taxid']
    log:
        "logs/construct_augustus_protein_set/{augustus_protein}.log"
    # conda:
    #     "envs/toolbox.yaml"
    run:
        augustus_protein_set = request_api.get_all_proteins_from_taxon({params.taxid})

        with open({output.protein_set}, 'w') as file:
            for i in augustus_protein_set:
                file.write(i)


rule filter_augustus_protein_set:
    input: 
        protein_set_redundant = "resources/proteins/augustus/{augustus_protein}_protein_set_redundant.fa"
    output:
        protein_set_non_redundant = "resources/proteins/augustus/{augustus_protein}_protein_set.fa"
    log:
        "logs/filter_protein_set/{augustus_protein}.log"
    # conda:
    #     "envs/toolbox.yaml"
    threads:
        20
    shell:
        """
        cd-hit -i {input.protein_set_redundant} -o {output.protein_set_non_redundant} -c 0.9 -n 5 -g 1 -M 16000 -d 0 -T {threads}
        """

rule filter_main_protein_set:
    input: 
        protein_set_redundant = "resources/proteins/main/{main_protein}_protein_set_redundant.fa"
    output:
        protein_set_non_redundant = "resources/proteins/main/{main_protein}_protein_set.fa"
    log:
        "logs/filter_protein_set/{main_protein}.log"
    # conda:
    #     "envs/toolbox.yaml"
    threads:
        20
    shell:
        """
        cd-hit -i {input.protein_set_redundant} -o {output.protein_set_non_redundant} -c 0.9 -n 5 -g 1 -M 16000 -d 0 -T {threads}
        """


rule construct_transcript_set:
    output:
        transcript_set = "resources/transcripts/{transcripts}_set_redundant.fa",
    params:
        taxid = lambda w: INFOS_SET_TRANSCRIPTS["{}".format(w.transcripts)]['taxid']
    log:
        "logs/construct_transcript_set/{transcripts}.log"
    # conda:
    #     "envs/toolbox.yaml"
    shell:
        """
        fetchAllTsaByTaxon.sh {params.taxid} {output.transcript_set}
       """


rule filter_transcript_set:
    input:
        transcript_set_redundant = "resources/transcripts/{transcripts}_set_redundant.fa"
    output:
        transcript_set_non_redundant = "resources/transcripts/{transcripts}_set.fa"
    log:
        "logs/filter_transcript_set/{transcripts}.log"
    # conda:cza m
    #     "envs/toolbox.yaml"
    threads:
        20      
    shell:
        """
        cd-hit-est -i {input.transcript_set_redundant} -o {output.transcript_set_non_redundant} -c 0.95 -n 10 -g 1 -M 16000 -d 0 -T {threads}
        """