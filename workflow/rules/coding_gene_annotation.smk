rule maker_rnd1:
    input:
        genome = "resources/genomes/{specie}_genome.fa",
        repeats = rules.repeat_masker.output.repeats_gff,
        main_protein = get_main_protein_set,
        transcript_set = get_transcript_set
    output:
        annotation = "results/maker_rnd1/{specie}.gff",
    log:
        "logs/maker_rnd1/{specie}.log"
    conda:
        "envs/annotation.yaml"
    shell:
        "touch {output}"

rule maker_aug:
    input:
        genome = "resources/genomes/{specie}_genome.fa",
        repeats = rules.repeat_masker.output.repeats_gff,
        augustus_protein = get_augustus_protein_set,
        transcript_set = get_transcript_set
    output:
        "results/maker_rndAug/{specie}.gff",
    shell:
        "touch {output}"

rule augustus_rnd2:
    input:
        genome="resources/genomes/{specie}_genome.fa",
        annot="results/maker_rndAug/{specie}.gff"
    output:
        genome="results/augustus_rnd2/{specie}_augustus.hmm"
    shell:
        "touch {output}"

rule snap_rnd2:
    input:
        genome="resources/genomes/{specie}_genome.fa",
        annot="results/maker_rnd1/{specie}.gff"
    output:
        genome="results/snap_rnd2/{specie}_augustus.hmm"
    shell:
        "touch {output}"

rule maker_rnd2:
    input:
        maker="results/maker_rnd1/{specie}.gff",
        augustus="results/augustus_rnd2/{specie}_augustus.hmm",
        snap="results/snap_rnd2/{specie}_augustus.hmm"
    output:
        "results/maker_rnd2/{specie}.gff"
    shell:
        "touch {output}"

rule augustus_rnd3:
    input:
        genome="resources/genomes/{specie}_genome.fa",
        annot="results/maker_rnd2/{specie}.gff"
    output:
        genome="results/augustus_rnd3/{specie}_augustus.hmm"
    shell:
        "touch {output}"

rule snap_rnd3:
    input:
        genome="resources/genomes/{specie}_genome.fa",
        annot="results/maker_rnd2/{specie}.gff"
    output:
        genome="results/snap_rnd3/{specie}_augustus.hmm"
    shell:
        "touch {output}"

rule maker_rnd3_tRNA_scanSE:
    input:
        genome="resources/genomes/{specie}_genome.fa",
        maker="results/maker_rnd2/{specie}.gff",
        augustus="results/augustus_rnd3/{specie}_augustus.hmm",
        snap="results/snap_rnd3/{specie}_augustus.hmm"
    output:
        "results/maker_rnd3/{specie}.gff"
    shell:
        "touch {output}"