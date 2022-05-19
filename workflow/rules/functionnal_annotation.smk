
# rule remove_isoformes:
#     input:
#     output:
#     shell:

rule split_proteome:
    input:
    # proteome = "results/pseudogenes/{specie}_nopseudo.fa"
        proteome = "/data/merlat/CompEvo/resources/{specie}_proteins.fa"
    output:
        protein = "results/{specie}/functionnal/split_proteom/{specie}_proteins.part-{number}.fa"
    params:
        out_dir = "results/{specie}/functionnal/split_proteom/"
    # logs:
    #     "logs/{specie}/functionnal/split_proteom/{specie}_proteins.part-{number}.fa"
    conda:
        get_conda('toolbox')
    shell:
        """
        protein_number=$(grep '>' {input.proteome}|wc -l)
        echo $protein_number
        fasta-splitter --n-parts $protein_number {input.proteome} --out-dir {params.out_dir}
        """


rule blast:
    input:
        # proteome = "results/pseudogenes/{specie}_nopseudo.fa"
        proteome = rules.split_proteome.output.protein
    output:
        blast = "results/{specie}/functionnal/blast/{specie}_proteins.part-{number}.blast.xml"
    params:
        bank = "/gstock/user/merlat/Annotation/blast-uniprot/blast-uniprot",
        out_dir = "results/{specie}/functionnal/blast",
        base_name = "{specie}_proteins.part-{number}.blast"
    conda:
        get_conda('toolbox')
    threads:
        1
    shell:
        """
        exogap=$(pwd)
        if [ ! -d {params.out_dir} ]; then
            mkdir {params.out_dir}
        fi
        cd {params.out_dir}

        blastp -query $exogap/{input.proteome} -db {params.bank} -outfmt 5 -out {params.base_name}.xml -evalue 1.0E-3 -word_size 3 -max_hsps 20 -num_threads {threads} -qcov_hsp_perc 33
        """

rule interproscan:
    input:
        proteome = rules.split_proteome.output.protein
    output:
        interproscan = "results/{specie}/functionnal/interproscan/{specie}_proteins.part-{number}.ips.xml"
    params:
        out_dir = "results/{specie}/functionnal/interproscan",
        base_name = "{specie}_proteins.part-{number}.ips"
    threads:
        1
    conda:
        get_conda('toolbox')
    shell:
        """
        exogap=$(pwd)
        if [ ! -d {params.out_dir} ]; then
            mkdir {params.out_dir}
        fi
        cd {params.out_dir}

        interproscan.sh -dp -goterms -iprlookup -pa -t p -i $exogap/{input.proteome} -f TSV,XML,GFF3 -cpu {threads}
        """

rule merge_blast:
    input:
        mini_blast = expand("results/{specie}/functionnal/blast/{specie}_proteins.part-{number}.blast.xml")
    output:
        all_blast = "results/{specie}/functionnal/blast/{specie}_proteins.blast.xml"
    params:
        mergeblastxml = config['MergeBlastXml']
    shell:
        """
        {params.mergeblastxml} {input.miniblast} > {output.all_blast}
        """


rule merge_interproscan:
    input:
        mini_ips = expand("results/{specie}/functionnal/interproscan/{specie}_proteins.part-{number}.ips.xml")
    output:
        all_ips = "results/{specie}/functionnal/interproscan/{specie}_proteins.ips.xml"
rule blast2go:
    input:
        interproscan="results/interproscan/{specie}_interproscan.fa",
        blast="results/blast/{specie}_blast.fa"
    output:
        "results/blast2go/{specie}_blast2go.fa"
    shell:
        "touch {output}"

