#!/usr/bin/env python

#************************************************#
#                rename_repeats.py               #
#            written by Dorine Merlat            #
#                 April 01, 2022                 #
#                                                #
#     Rename header of repetitive elements.      #
#************************************************#

import argparse
from Bio import SeqIO
import re

def rename(input, output, prefix):
    with open(output, 'w') as file:
        for record in SeqIO.parse(input, 'fasta'):
            res = re.search(r'rnd-(?P<rnd>\d+)_family-(?P<family>\d+)\#(?P<class>.+) \(', record.description)
            record.id = prefix + '_' + res.group('rnd') + '-' + res.group('family') + '#' + res.group('class')
            record.description = ''
            file.write(record.format('fasta'))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", help='FASTA file input (required)', type=str, required=True, metavar="FASTA")
    parser.add_argument("-o", "--output", help='FASTA file output (required)', type=str, required=True, metavar="FASTA")
    parser.add_argument("-p", "--prefix", help='Prefix to use (required)', type=str, required=True, metavar="FASTA")
    args = parser.parse_args()

    rename(input = args.input, output = args.output, prefix = args.prefix)

if __name__ == "__main__":
    main()