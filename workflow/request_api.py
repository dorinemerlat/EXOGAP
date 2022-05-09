import requests
import argparse
import sys
import json


def request_api_txt(requestURL):
    r = requests.get(requestURL, headers={ "Accept" : "text/x-fasta"})

    if not r.ok:
        r.raise_for_status()
        sys.exit()

    return r.text


def request_api_json(requestURL):
    r = requests.get(requestURL, headers={ "Accept" : "application/json"})
    
    if not r.ok:
        r.raise_for_status()
        sys.exit()

    return r.json()


def get_taxid_from_taxon(taxid):
    url = 'https://lbgi.fr/api/taxonomy/descendants/' + taxid
    decoded = request_api_json(url)

    data = decoded['data']
    
    list_taxid = list()

    for i in data : 
        if 'rank' in i and i['rank'] in ["Subspecies", "Species"]:
            list_taxid.append(str(i['id']))

    return list_taxid


def get_upid_from_taxidlist(taxid_list):
    list_upid = list()

    for taxid in taxid_list:  
        requestURL = "https://www.ebi.ac.uk/proteins/api/proteomes?offset=0&size=-1&taxid=" + taxid + "&is_ref_proteome=true"
        responseBody = request_api_json(requestURL)
        
        if len(responseBody) > 0:
            list_upid.append(responseBody[0]['upid'])
    
    return list_upid


def get_proteinAccess_from_upid(upid_list):
    accession_list = list()

    for upid in upid_list:
        requestURL = "https://www.ebi.ac.uk/proteins/api/proteomes/proteins/" + upid + "?reviewed=true"
        responseBody = request_api_json(requestURL)
        
        component = responseBody['component']
        for i in responseBody['component']: # i = item in a list
            for j in i['protein']:
                accession_list.append(j['accession'])

    return accession_list


def get_protein_from_proteinAccess(accession_list):
    sequence_list = list()

    for accession in accession_list:
        requestURL = "https://www.ebi.ac.uk/proteins/api/proteins?offset=0&size=-1&accession=" + accession + "&reviewed=true&isoform=0&seqLength=10-100000000"
        responseBody = request_api_txt(requestURL)
        
        if len(responseBody) > 0:
            sequence_list.append(responseBody)

    return sequence_list


def get_protein_from_taxid(taxid_list):
    sequence_list = list()

    for taxid in taxid_list:
        requestURL = "https://www.ebi.ac.uk/proteins/api/proteins?offset=0&size=-1&taxid=" + taxid + "&isoform=0&seqLength=10-100000000"
        responseBody = request_api_txt(requestURL)
        
        if len(responseBody) > 0:
            sequence_list.append(responseBody)

    return sequence_list


def get_reviewed_proteins_of_reference_proteome_from_taxon(taxon):
    taxid_list = get_taxid_from_taxon(taxon)
    upid_list = get_upid_from_taxidlist(taxid_list)
    accession_list = get_proteinAccess_from_upid(upid_list)
    sequence_list = get_protein_from_proteinAccess(accession_list)
    print(len(sequence_list))
    return sequence_list


def get_all_proteins_from_taxon(taxon):
    taxid_list = get_taxid_from_taxon(taxon)
    sequence_list = get_protein_from_taxid(taxid_list)
    print(len(sequence_list))
    return sequence_list


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--taxid", help='TaxID of a group of specie', required = True, type=str, metavar="XX")
    parser.add_argument("-o", "--out", help='Output', type=str, default = 'no', metavar="XX")
    args = parser.parse_args()

    # get_reviewed_proteins_of_reference_proteome_from_taxon(args.taxid)    
    get_all_proteins_from_taxon(args.taxid)


if __name__ == "__main__":
    main()