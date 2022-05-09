
    input:
        "results/maker_rnd3/{specie}.gff"
    output:
        "results/pseudogenes/{specie}_pseudogenes.fa"
    shell:
        "touch {output}"
