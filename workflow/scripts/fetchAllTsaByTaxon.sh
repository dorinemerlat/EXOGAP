#!/bin/sh
# Script adapté à partir de https://www.biostars.org/p/221242/
# Nécessite d'installer edirect et sratoolkit
# Récupérer les TSA

TAX=$1
OUTPUT=$2

RESULT=`esearch -db nuccore -query '((txid'${TAX}'[Organism:exp]) AND ( "tsa master"[Properties]))' | \
 efetch -format xml | tee ${TAX}.esearch.xml` # save the xml result for further reference
#  RESULT=`esearch -db nuccore -query '((txid'${TAX}'[Organism:exp]) AND ( "tsa master"[Properties]))' | \
#  efetch -format xml | tee ${TAX}.esearch.xml` # save the xml result for further reference
ID=`echo $RESULT | xtract -pattern Seq-entry  -element Textseq-id_name`  # extracts the seq-id name field from the tsa or wgs master
# echo $ID > id_${TAX}.txt

# ID=`cat id_${TAX}.txt`
for I in $ID ; do
  echo Downloading $I ...
  if [ -e $I.fasta ]
  then
    echo " skipping because file exists."
    continue # skip if the file has been downloaded already
   fi
    fasterq-dump --fasta -e 12 $I # use SRA toolkit fasterq-dump with the option to make a fasta file and the standard header.
done

cat ${TAX}.esearch.xml |grep 'Org-ref_taxname' > $OUTPUT
sed -i -e "s|<Org-ref_taxname>||g" $OUTPUT 
sed -i -e "s|</Org-ref_taxname>||g" $OUTPUT 
sed -i -e "s|^ *||g" $OUTPUT 