rule merge_all:
    input:
        cgenes="results/blast2go/{specie}_blast2go.fa",
        ncgenes="results/ncrna/{specie}_ncrna_withfunctionnal.fa"
    output:
        "results/all/{specie}_all.fa"
    shell:
        "touch {output}"

rule make_genbank:
    input:
        "results/all/{specie}_all.fa"
    output:
        "results/all/{specie}_all.gb"
    shell:
        "touch {output}"