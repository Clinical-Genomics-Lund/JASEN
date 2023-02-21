#!/bin/bash

mkdir assets &> /dev/null
mkdir -p assets/genomes/{escherichia_coli,klebsiella_pneumoniae,staphylococcus_aureus} &> /dev/null
mkdir assets/card &> /dev/null
mkdir assets/cgmlst &> /dev/null
mkdir -p assets/mlst_db/{blast,pubmlst} &> /dev/null

scriptdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
assdir="${scriptdir}/../assets/"

source activate jasen

## DBS

#CARD db
cd ${assdir}/card
wget https://card.mcmaster.ca/download/0/broadstreet-v3.1.4.tar.bz2
tar -xjf broadstreet-v3.1.4.tar.bz2
ariba prepareref -f nucleotide_fasta_protein_homolog_model.fasta --all_coding yes --force tmpdir
cp tmpdir/* .

#MLST db
#wget https://card.mcmaster.ca/download/5/ontology-v3.1.4.tar.bz2
cd ${assdir}/mlst_db
bash ./mlst-download_pub_mlst.sh
bash ./mlst-make_blast_db.sh
#wget https://raw.githubusercontent.com/tseemann/mlst/master/db/blast/mlst.fa --no-check-certificate

#Finder dbs
cd ${assdir}/kma && make
cd ${assdir}/virulencefinder_db
export PATH=$PATH:/${assdir}/kma
python INSTALL.py ${assdir}/kma/kma_index
cd ${assdir}/resfinder_db
python INSTALL.py ${assdir}/kma/kma_index
cd ${assdir}/pointfinder_db
python INSTALL.py ${assdir}/kma/kma_index

## Organisms

#Saureus
cd ${assdir}/..
python bin/download_ncbi.py NC_002951.2 assets/genomes/staphylococcus_aureus
cd ${assdir}/genomes/staphylococcus_aureus
bwa index NC_002951.2.fasta
mkdir -p ${assdir}/cgmlst/staphylococcus_aureus/alleles &> /dev/null
cd ${assdir}/cgmlst/staphylococcus_aureus/alleles  
wget https://www.cgmlst.org/ncs/schema/141106/alleles/ --no-check-certificate
unzip index.html
cd ${assdir}/cgmlst/staphylococcus_aureus/ 
echo "WARNING! Prepping cgMLST schema. This takes a looong time. Put on some coffee"
chewie PrepExternalSchema -i ${assdir}/cgmlst/staphylococcus_aureus/alleles -o ${assdir}/cgmlst/staphylococcus_aureus/alleles_rereffed \
	--cpu 1 --ptf ${assdir}/prodigal_training_files/Staphylococcus_aureus.trn

#Ecoli
cd ${assdir}/..
python bin/download_ncbi.py NC_000913.3 assets/genomes/escherichia_coli
cd ${assdir}/genomes/escherichia_coli
bwa index NC_000913.3.fasta
mkdir -p ${assdir}/cgmlst/escherichia_coli/alleles &> /dev/null
cd ${assdir}/cgmlst/escherichia_coli/alleles
wget https://www.cgmlst.org/ncs/schema/5064703/alleles/ --no-check-certificate
unzip index.html
cd ${assdir}/cgmlst/escherichia_coli/
echo "WARNING! Prepping cgMLST schema. This takes a looong time. Put on some coffee"
chewie PrepExternalSchema -i ${assdir}/cgmlst/escherichia_coli/alleles -o ${assdir}/cgmlst/escherichia_coli/alleles_rereffed \
	--cpu 1 --ptf ${assdir}/prodigal_training_files/Escherichia_coli.trn

#Kpneumoniae
cd ${assdir}/..
python bin/download_ncbi.py NC_016845.1 assets/genomes/klebsiella_pneumoniae
cd ${assdir}/genomes/klebsiella_pneumoniae
bwa index NC_016845.1.fasta
mkdir -p ${assdir}/cgmlst/klebsiella_pneumoniae/alleles &> /dev/null
cd ${assdir}/cgmlst/klebsiella_pneumoniae/alleles
wget https://www.cgmlst.org/ncs/schema/2187931/alleles/ --no-check-certificate
unzip index.html

cd ${assdir}/..
