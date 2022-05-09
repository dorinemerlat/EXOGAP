while getopts :f:o:c:j:k:u:r: flag
do
    case "${flag}" in
        f) fasta=${OPTARG};;
        o) repeatsDir=${OPTARG};;
        c) cpu=${OPTARG};;
        s) specie=${OPTARG};;
        k) known_repeats=${OPTARG};;
        u) unknown_repeats=${OPTARG};;
        r) repset=${OPTARG};;
        *) echo 'run_busco.sh -f <genome/proteome.fa> -o <path_repeats_dir> -c <cpu> -j <specie> -k <known.fa> -u <unknown.fa> -r <repbase>'
           exit 0
    esac
done

mkdir $repeatsDir
$repeatsDir

# First iteration: RepBase or RepSet
mkdir repBase_mask
RepeatMasker -pa $cpu -e ncbi -nolow -lib $repset -a -gccalc -norna -excln \
-gff -s -xsmall -gccalc -excln -gff -s -dir repBase_mask $fasta
rename -v -E "s/[\w_]+\.fa/${specie}_repBase_mask/" repBase_mask/*

# Second iteration: Known repeats
mkdir known_mask
RepeatMasker -pa $cpu -e ncbi -nolow -lib $known_repeats -a -gccalc -norna -excln \
    -gff -s -dir known_mask repBase_mask/*.masked
rename -v "s/${specie}_repBase_mask.masked/${specie}_known_mask/" known_mask/*

# Third iteration: Unknown repeats
mkdir unknown_mask
RepeatMasker -pa $cpu -e ncbi -nolow -lib $unknown_repeats -a -gccalc -norna \
    -excln -gff -s -dir unknown_mask repBase_mask/*.masked
rename -v "s/${specie}_known_mask.masked/${specie}_unknown_mask/" unknown_mask/*

# Processing of all repeats
mkdir final_mask
cp unknown_mask/*.masked final_mask/${specie}_finalMask.fa
cat repBase_mask/*.out known_mask/*.out unknown_mask/*.out > final_mask/${specie}_finalMask.out

gunzip repBase_mask/*.cat.gz known_mask/*.cat.gz unknown_mask/*.cat.gz 
cat repBase_mask/*.cat known_mask/*.cat unknown_mask/*.cat > final_mask/${specie}_finalMask.cat

cd final_mask
ProcessRepeats -lib $repset -a ${specie}_finalMask.cat

# Creation of the GFF3
${RepeatMaskerPATH}rmOutToGFF3.pl ${specie}_finalMask.out > ${specie}_finalMask.gff3

#Isolement des repeats complexes
grep -v -e "Satellite" -e ")n" -e "-rich" ${specie}_finalMask.gff3 > ${specie}_finalMask_complex.gff3

####### Reformatage pour que ça fonctionne avec Maker
cat ${specie}_finalMask_complex.gff3 | \
    perl -ane '$id; if(!/^\#/){@F = split(/\t/, $_); chomp $F[-1];$id++; $F[-1] .= "\;ID=$id"; $_ =join("\t", @F)."\n"} print $_' \
    > ${specie}_finalMask_complex_reformat.gff3

####### Préparation des résultats pour l'analyse ultérieur
# Reformatage du .out
sed -e 's/\s\+/,/g' ${specie}_finalMask.out > ${specie}_finalMask.out.csv
sed -i '/^,SW/d' ${specie}_finalMask.out.csv
sed -i '/^$/d' ${specie}_finalMask.out.csv
sed -i -e 's|^,||g' ${specie}_finalMask.out.csv
sed -i -e 's|,$||g' ${specie}_finalMask.out.csv
sed -i -e 's|(left),|(left),symbol,|g' ${specie}_finalMask.out.csv
sed -i -e 's|,\*$|\*|g' ${specie}_finalMask.out.csv

g=$(grep 'total length' *tbl |cut -d ':' -f 2 |cut -d 'b' -f 1)
specie_name=$(echo $specie |sed 's/^./\u&/')
summarize_TE.py -i ${specie}_finalMask.out.csv -s "$specie_name" -l $g \
    -o ../../../results/repeats/${specie}

# Re-calculer la divergence adapté au contenu en GC
align_file=${specie}_finalMask.align
${RepeatMaskerPATH}calcDivergenceFromAlign.pl -s ${align_file}.divsum -a ${align_file}_with_div $align_file

# Calcul du paysage de repeat
${RepeatMaskerPATH}createRepeatLandscape.pl -div ${align_file}.divsum -g $g > ${align_file}.html

# Conversion du html en csv
python ${bin}html2csv.py ${align_file}.html ${ResDirTE}${specie}_TE_divergence.csv
