rule rnammer:
    input:
        genome="resources/genomes/{specie}_genome.fa"
    output:
        "results/rnammer/{specie}_rnammer.fa"
    shell:
        "touch {output}"

rule barnap:
    input:
        genome="resources/genomes/{specie}_genome.fa"
    output:
        "results/barnnap/{specie}_barrnap.fa"
    shell:
        "touch {output}"

rule infernal:
    input:
        genome="resources/genomes/{specie}_genome.fa"
    output:
        "results/infernal/{specie}_infernal.fa"
    shell:
        "touch {output}"

rule post_process_ncrna:
    input:
        rnammer="results/rnammer/{specie}_rnammer.fa",
        barnnap="results/barnnap/{specie}_barrnap.fa",
        infernal="results/infernal/{specie}_infernal.fa",
        maker="results/maker_rnd3/{specie}.gff"
    output:
        "results/ncrna/{specie}_ncrna.fa"
    shell:
        "touch {output}"

rule functionnal_ncgene:
    input:
        ncgenes="results/ncrna/{specie}_ncrna.fa"
    output:
        ncgenes="results/ncrna/{specie}_ncrna_withfunctionnal.fa"
