
rule blast:
    input:
        "results/pseudogenes/{specie}_pseudogenes.fa"
    output:
        "results/blast/{specie}_blast.fa"
    shell:
        "touch {output}"

rule interproscan:
    input:
        "results/pseudogenes/{specie}_pseudogenes.fa"
    output:
        "results/interproscan/{specie}_interproscan.fa"
    shell:
        "touch {output}"

rule blast2go:
    input:
        interproscan="results/interproscan/{specie}_interproscan.fa",
        blast="results/blast/{specie}_blast.fa"
    output:
        "results/blast2go/{specie}_blast2go.fa"
    shell:
        "touch {output}"
