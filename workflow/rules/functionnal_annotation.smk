rule blast:
    input:
        proteome = "resources/{specie}_proteins.fa"
    output:
        blast = "results/{specie}/functionnal/blast/{specie}_proteins.blast.xml"
    params:
        bank = config['functionnal']['blastBank'],
        out_dir = "results/{specie}/functionnal/blast"
    conda:
        get_conda('toolbox')
    threads:
        1
    shell:
        """
        exogap=$(pwd)
        
        mkdir -p {params.out_dir}
        cd {params.out_dir}

        blastp -query $exogap/{input.proteome} -db {params.bank} -outfmt 5 -out $exogap/{output.blast} -evalue 1.0E-3 -word_size 3 -max_hsps 20 -num_threads {threads} -qcov_hsp_perc 33
        """

rule interproscan:
    input:
        proteome = "resources/{specie}_proteins.fa"
    output:
        interproscan = "results/{specie}/functionnal/interproscan/{specie}_proteins.fa.xml",
    params:
        out_dir = "results/{specie}/functionnal/interproscan"
    threads:
        1
    conda:
        get_conda('toolbox')
    shell:
        """
        exogap=$(pwd)

        mkdir -p {params.out_dir}
        cd {params.out_dir}

        interproscan.sh -dp -goterms -iprlookup -pa -t p -i $exogap/{input.proteome} -f TSV,XML,GFF3 -cpu {threads}
        """

    
rule blast2go:
    input:
        interproscan = rules.blast.output.blast,
        blast = rules.interproscan.output.interproscan
    output:
        b2g = "results/{specie}/functionnal/blast2go/{specie}_blast2go.fa"
    shell:
        """ 
        "touch {output.b2g}"
        """


# rule run_blast2go:
#     input:
#         blast = rules.merge_blast.output.all_blast,
#         ips = rules.merge_interproscan.output.all_ips
#     output:
#         res = "results/{specie}/functionnal/b2g/{specie}_results.txt"
#     params:
#         blast2go = config['blast2go']
#     shell:
#         'touch {output.res}'
