#!/usr/bin/env python

#************************************************#
#               sorting_repeats.py               #
#            written by Dorine Merlat            #
#                 April 01, 2022                 #
#                                                #
#    Sorting known and unknowns from a library   #
#            of repetitive elements.             #
#************************************************#

from Bio import SeqIO
import re
import argparse

def sorting(input, unknown_file, known_file):
    unknown = open(unknown_file, 'w')
    known = open(known_file, 'w')

    for seq_record in SeqIO.parse(input, 'fasta'):
        if re.match(r'.*#Unknown', seq_record.id):
            unknown.write(seq_record.format('fasta'))
        else :
            known.write(seq_record.format('fasta'))

    unknown.close()
    known.close()


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("-i", "--input", help='FASTA file to sort (required)', type=str, required=True, metavar="FASTA")
    parser.add_argument("-k", "--knowns", help='FASTA file output with the known repetitive elements (required)', type=str, required=True, metavar="FASTA")
    parser.add_argument("-u", "--unknowns", help='FASTA file output with the unknown repetitive elements (required)', type=str, required=True, metavar="FASTA")

    args = parser.parse_args()

    sorting(args.input, args.unknowns, args.knowns)
    

if __name__ == "__main__":
    main()