rule install_toolbox:
    output:
        temp('results/check_config/install_conda_toolbox.txt')
    conda: get_conda("toolbox")
    shell:
        'touch {output}'

rule install_annotation:
    output:
        temp('results/check_config/install_conda_annotation.txt')
    conda: get_conda("annotation")
    shell:
        'touch {output}'

rule install_repeatmodeler:
    output:
        temp('results/check_config/install_conda_repeatmodeler.txt')
    conda: get_conda("repeatmodeler")
    shell:
        'touch {output}'

rule check_repeat_masker:
    input:
        annot_install = rules.install_annotation.output,
        lib_embl = config['repeats']['lib_embl']
    output:
        annot_config = "results/check_config/config_{annotation_env}_repeat_masker.txt"
    params:
        link_files = "{annotation_env}/bin",
        real_files = "{annotation_env}/share/RepeatMasker",
        path_annotation = find_environnement('annotation')
    conda:
        get_conda('annotation')
    log:
        "logs/check_config/{annotation_env}.log"
    shell:
        """
        search_dir={params.real_files}

        # Create symlinks for the RepeatMasker scripts
        real_dir={params.path_annotation}/share/RepeatMasker
        # Create symlinks for the RepeatMasker scripts
        list_file=$(ls $real_dir)
        for file in $real_dir/* ; do
            echo $file
            if [[ "$file" == *".pm"* ]] ; then
                file_name=$(echo $file| rev |cut -d '/' -f 1 |rev)
                link={params.path_annotation}/bin/$file_name
                file=$(pwd)/$file
                if [[ ! -L "$link" ]] ; then
                    echo ln -s $file $link
                    ln -s $file $link
                fi
            fi
        done

        # Create a symlink for the repbase library
        lib_embl_symlink=$(pwd)/{params.path_annotation}/share/RepeatMasker/Libraries/RepeatMaskerLib.embl
        lib_embl=$(pwd)/{input.lib_embl}
        echo $lib_embl
        if [[ ! -L "$lib_embl_symlink" ]] ; then
            echo ln -s $lib_embl $lib_embl_symlink
            ln -s $lib_embl $lib_embl_symlink
        fi
        
        # # test if RepeatMasker and RepeatModeler works
        RepeatMasker -help |grep 'RepeatMasker version'
        rmOutToGFF3.pl -h

        touch {output.annot_config}
        """


rule check_repeat_modeler:
    input:
        annot_install = rules.install_repeatmodeler.output
    output:
        temp("results/check_config/config_{repeatmodeler_env}_rm.txt")
    params:
        link_files = "{repeatmodeler_env}/bin",
        real_files = "{repeatmodeler_env}/share/RepeatMasker",
        path_repeatmodeler = find_environnement('repeatmodeler')
    conda:
        get_conda('repeatmodeler')
    log:
        "logs/check_config/{repeatmodeler_env}.log"
    shell:
        """
        exogap=$(pwd)
        # configuration of paths for RepeatModeler
        bin_dir=$exogap/{params.path_repeatmodeler}/bin
        cd {params.path_repeatmodeler}/share/RepeatModeler

        echo $bin_dir
        printf "\n$bin_dir/perl\n$bin_dir\ny\n" |\
        perl ./configure -cdhit_dir $bin_dir \ -abblast_dir $bin_dir \
        -genometools_dir $bin_dir -ltr_retriever_dir $bin_dir \
        -ninja_dir $bin_dir -recon_dir $bin_dir -mafft_dir $bin_dir \
        -rmblast_dir $bin_dir -trf_prgm $bin_dir -repeatmasker_dir $bin_dir \
        -rscout_dir $bin_dir
        
        # symblink of repeatmasker in bin
        cd $exogap
        
        mv $bin_dir/ninja $bin_dir/Ninja

        real_dir={params.path_repeatmodeler}/share/RepeatMasker
        # Create symlinks for the RepeatMasker scripts
        list_file=$(ls $real_dir)
        for file in $real_dir/* ; do
            echo $file
            if [[ "$file" == *".pm"* ]] ; then
                file_name=$(echo $file| rev |cut -d '/' -f 1 |rev)
                link={params.path_repeatmodeler}/bin/$file_name
                file=$(pwd)/$file
                if [[ ! -L "$link" ]] ; then
                    echo ln -s $file $link
                    ln -s $file $link
                fi
            fi
        done

        # RepeatModeler |grep 'RepeatModeler - Model repetitive DNA'

        touch {output}
        """
                

        # cd $exogap

        # # symblink of repeatmasker in bin
        # search_dir={params.real_files}

        # # Create symlinks for the RepeatMasker scripts
        # for entry in "$search_dir"/* ; do
        #     if [[ "$entry" == *".pm"* ]] ; then
        #         file_name=$(echo $entry| rev |cut -d '/' -f 1 |rev)
        #         link={params.link_files}/$file_name
        #         entry=$(pwd)/$entry
        #         if [[ ! -L "$link" ]] ; then
        #             echo ln -s $entry $link
        #             ln -s $entry $link
        #         fi
        #     fi
        # done

        # echo {output}
        # touch {output}

rule check_maker:
    input:
        annot_install = rules.install_annotation.output
    output:
        annot_config = temp("results/check_config/config_{annotation_env}_maker.txt")
    shell:
        """
        # test if maker works
        maker --version
        """

rule check_all_config:
    input:
        repeat_masker = expand("results/check_config/config_{annotation_env}_repeat_masker.txt", annotation_env = 'annotation'),
        repeatmodeler = expand("results/check_config/config_{repeatmodeler_env}_rm.txt", repeatmodeler_env = 'repeatmodeler')
    output:
        all = "results/check_config/check_all_config.txt"
    conda:
        get_conda('annotation')
    log:
        "logs/check_config/all.log"
    shell:
        "touch {output.all}"