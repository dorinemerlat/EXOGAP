#!/usr/bin/env python

from Bio import SeqIO
import re
import json
import argparse

def change_seq_names(fasta_in):

    # Names of out files
    extension = re.search(r'(?P<name>.fa|fasta)', fasta_in).group('name')
    fasta_out = fasta_in.replace(extension, '_rename.fa')
    json_out = fasta_in.replace(extension, '_rename.json')

    dictionnary = {}
    num_seq = 1

    with open(fasta_out, 'w') as file : 
        for record in SeqIO.parse(fasta_in, 'fasta') :
            if record.id not in dictionnary : 
                new_name = 'SEQ' + str(num_seq)
                num_seq += 1
                dictionnary[record.id] = new_name
            record.id = dictionnary[record.id]
            record.description = ""
            file.write(record.format('fasta'))

    with open(json_out, 'w') as file:
        json.dump(dictionnary, file)

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", help='FASTA file to reformat', type=str, required=True, metavar="FILE")
    args = parser.parse_args()

    change_seq_names(args.input)

    print('\nReformating done\n')

if __name__ == "__main__":
    main()