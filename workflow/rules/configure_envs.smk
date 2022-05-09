# def find_yaml(environnement):
#     for file_name in os.listdir('.snakemake/conda'):
#         if '.yaml' in file_name:
#             with open('.snakemake/conda/' + file_name, 'r') as file:
#                 file = file.readlines()
#             if environnement in file[0]:
#                 return '.snakemake/conda/' + file_name

# def find_environnement(environnement):
#     yaml = find_yaml(environnement)
#     return yaml.replace('.yaml', '')

# def get_conda(environnement):
#     return "../envs/" + environnement + ".yaml"

rule install_annot:
    output:
        temp('install_conda_annotation.txt'
    conda:
        "/enadisk/maison/merlat/Scripts/EXOGAP/workflow/envs/annotation.yaml"
    shell:
        'touch {output}'
        
# rule check_repeat_masker:
#     input:
#         # lib_embl = config['repeat_masker_libraries']['lib_embl']
#         lib_embl = "resources/RMRBSeqs.embl"
#         # cross_match = "{annotation_env}/share/RepeatMasker/CrossmatchSearchEngine.pm",
#         # search_engine = "{annotation_env}/share/RepeatMasker/SearchEngineI.pm",
#         # search_results_coll = "{annotation_env}/share/RepeatMasker/SearchResultCollection.pm",
#         # search_results = "{annotation_env}/share/RepeatMasker/SearchResult.pm",
#     output:
#         lib_embl_symb = "{annotation_env}/share/RepeatMasker/Libraries/RepeatMaskerLib.embl",
#         taxonomy_symb = "{annotation_env}/bin/Taxonomy.pm",
#         temp = "bla_{annotation_env}.txt"
#     params:
#         link_files = "{annotation_env}/bin",
#         real_files = "{annotation_env}/share/RepeatMasker"
#     conda:
#         get_conda('annotation')
#     log:
#         "logs/{annotation_env}/repeats_masker.log"
#     shell:
#         """
#         search_dir={params.real_files}

#         # # Create symlinks for the RepeatMasker scripts
#         # for entry in "$search_dir"/* ; do
#         #     if [[ "$entry" == *".pm"* ]] ; then
#         #         file_name=$(echo $entry| rev |cut -d '/' -f 1 |rev)
#         #         link={params.link_files}/$file_name
#         #         entry=$(pwd)/$entry
#         #         if [[ ! -L "$link" ]] ; then
#         #             echo ln -s $entry $link
#         #             ln -s $entry $link
#         #         fi
#         #     fi
#         # done

#         # # Create a symlink for the repbase library
#         # lib_embl=$(pwd)/{input.lib_embl}
#         # echo $lib_embl
#         # if [[ ! -L "{output.lib_embl_symb}" ]] ; then
#         #     echo ln -s $lib_embl {output.lib_embl_symb}
#         #     ln -s $lib_embl {output.lib_embl_symb}
#         # fi
        
#         # # # test if RepeatMasker and RepeatModeler works
#         # RepeatMasker -help |grep 'RepeatMasker version'
#         # RepeatModeler -h
#         # CrossmatchSearchEngine.pm
#         """
# # rule check_repeat_modeler:
# #     input:
# #     output:
# #     shell:
# #         "touch {output}"

# # rule check_maker:
# #     input:
# #     output:
# #     shell:
# #         """
#         # # test if maker works
#         # maker --version
#         # """

# rule check_all_config:
#     input:
#         lib_embl_symb = expand("{annotation_env}/share/RepeatMasker/Libraries/RepeatMaskerLib.embl", annotation_env = find_environnement('annotation'))
#     output:
#         all = temp("results/check_config/everything_works.txt2")
#     shell:
#         "touch {output.all}"