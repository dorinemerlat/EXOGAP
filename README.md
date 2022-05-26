[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# EXOGAP User Guide
## EXotic Organism's Genome Annotation Pipeline
EXOGAP is a Snakemake workflow for the annotation of exotic (non-model) organism's genomes where the assembly quality can be variable.

## Authors
Dorine Merlat, iCube, University of Strasbourg, France, dorine.merlat@etu.unistra.fr

## What is EXOGAP?

With the development of NGS technologies, it is becoming easier to sequence genomes of new species. However, it is not always possible to obtain high quality assemblies. This is why we have developed EXOGAP, an automated annotation SnakeMake workflow adapted to non-model species assemblies of variable quality. 

It is based on the Maker, Augustus and Snap programs for the annotation of protein-coding genes, on Infernal, tRNA-Scan-SE, RNAmmer and Barnnap for the annotation of non-coding genes and on RepeatModeler and RepeatMasker for the annotation of repeated elements. 

It is very flexible and allows the prediction of protein-coding genes from transcriptomic and protein data that do not necessarily belong to the species to be annotated, but to more or less closely related species. This is very useful when the species of interest is one of the first sequenced in its phylum. 

In this user guide, you find all information about installation and usage of this pipeline.

## Getting Started

### ****Prerequisites****

At the time of release, MyriAnnot was tested with: 

- [SnakeMake 7.3.8](https://snakemake.readthedocs.io/en/stable/)
- [Gene-Mark-ES 4.*](http://opal.biology.gatech.edu/genemark/)
- [Rnammer 1.2](https://services.healthtech.dtu.dk/service.php?RNAmmer-1.2)
- [MergeBlastXML](http://lindenb.github.io/jvarkit/MergeBlastXml.html)
- [Blast2Go](https://www.biobam.com/blast2go-cli/)


### Installation

1. Install [SnakeMake](https://snakemake.readthedocs.io/en/stable/) following the procedure indicated [here](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

2. Manually install programs that cannot be installed by conda: [Gene-Mark-ES](http://opal.biology.gatech.edu/genemark/), [Rnammer](https://services.healthtech.dtu.dk/service.php?RNAmmer-1.2) and [MergeBlastXml](http://lindenb.github.io/jvarkit/MergeBlastXml.html)

    Being a SnakeMake workflow, most programs are installed via conda thanks to three dedicated environments: 
    - *annotation*: [Maker2](https://www.yandell-lab.org/software/maker.html) (3.01.03), [Agat](https://github.com/NBISweden/AGAT) (v0.8.0), [RepeatMasker](https://www.repeatmasker.org/) (4.1.2-p1), [Augustus](https://github.com/Gaius-Augustus/Augustus) (3.4.0), [Snap](https://github.com/KorfLab/SNAP) (2006-07-28), [T-RNA-scan-SE](http://lowelab.ucsc.edu/tRNAscan-SE/) (2.0.9), [Infernal](http://eddylab.org/infernal/) (1.1.4) and [Barnnap](https://github.com/tseemann/barrnap) (0.9).
    - *repeatmodeler*: [RepeatModeler](https://github.com/Dfam-consortium/RepeatModeler) (2.0.3)
    - *toolbox*: [Busco](https://busco.ezlab.org) (ov5.3.0), [CD-HIT](http://weizhong-lab.ucsd.edu/cd-hit/) (4.8.1), [SRA Tookit](https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=software) and [Entrez Direct](https://www.ncbi.nlm.nih.gov/books/NBK179288/), [Blast](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download) (2.12.0+) and [interproscan](https://github.com/ebi-pf-team/interproscan) (5.55_88.0)

    These environments are installed and used automatically thanks to the annotation.yaml and toolbox.yaml environment files (located in workflow/envs/). 


3. Clone the repository
    
    ```bash
    clone git https://github.com/dorinemerlat/EXOGAP.git
    ```


4. Check that all programs are installed and configured correctly

    ```bash
    cd EXOGAP
    ```


## Usage

1. Fill config.yaml file.

2. Let Snakemake install the needed conda environments:
    ```bash
    snakemake --use-conda --cores 4 --snakefile workflow/configure.smk
    ```
    Conda environements are installed to EXOGAP/.snakemake/conda/

3. Lauch EXOGAP to configurate the conda environment:
    ```bash
    snakemake --use-conda --cores 4 results/check_config/check_all_config.txt
    ```

3. Lauch EXOGAP with a output file indicated or without (if you want to annotate all the species present in the ressource directory)
    ```
    snakemake --cores <threads_number> --use-conda <final_file.txt>
    ```

## License

Distributed under the MIT License. See [LICENCE](https://github.com/dorinemerlat/EXOGAP/blob/main/LICENSE) for more information.