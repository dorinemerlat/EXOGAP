def get_conda(environnement):
    return "envs/" + environnement + ".yaml"

rule all:
    input:
        'results/check_config/install_conda_toolbox.txt',
        'results/check_config/install_conda_annotation.txt',
        'results/check_config/install_conda_repeatmodeler.txt'

        
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
