
# rule remove_isoformes:
#     input:
#     output:
#     shell:

rule blast:
    input:
        # proteome = "results/pseudogenes/{specie}_nopseudo.fa"
        proteome = "/data/merlat/CompEvo/resources/{specie}_proteins.fa"
    output:
        blast = "results/{specie}/functionnal/blast/{specie}_blast.xml"
    params:
        bank = "/gstock/user/merlat/Annotation/blast-uniprot/blast-uniprot",
        out_dir = "results/{specie}/functionnal/blast"
    conda:
        get_conda('toolbox')
    threads:
        32
    shell:
        """
        if [ ! -d {params.out_dir} ]; then
            mkdir {params.out_dir}
        fi
        cd {params.out_dir}

        blastp -query {input.proteome} -db {params.bank} -outfmt 5 -out {wildcards.specie}.xml -evalue 1.0E-3 -word_size 3 -max_hsps 20 -num_threads {threads} -qcov_hsp_perc 33
        """

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
