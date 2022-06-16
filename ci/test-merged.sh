#!/bin/bash

set -e

ROOT_DIR=`pwd`
export ROBOT_JAVA_ARGS=-Xmx7G

mkdir mirror
curl -L -o 'mirror/taxslim.owl' 'http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim.owl'
curl -L -o 'mirror/taxslim-disjoint-over-in-taxon.owl' 'http://purl.obolibrary.org/obo/ncbitaxon/subsets/taxslim-disjoint-over-in-taxon.owl'
curl -L -o 'mirror/chebi.owl.gz' 'http://purl.obolibrary.org/obo/chebi.owl.gz'
cd mirror
gunzip chebi.owl.gz
cd $ROOT_DIR

git clone --depth 1 'https://github.com/geneontology/go-ontology.git'
git clone --depth 1 'https://github.com/obophenotype/uberon.git'
git clone --depth 1 'https://github.com/obophenotype/cell-ontology.git'
git clone --depth 1 'https://github.com/oborel/obo-relations.git'

cd go-ontology/src/ontology
make go-base.owl
cd $ROOT_DIR

cd uberon/src/ontology
mkdir -p tmp
make uberon-base.owl
make bridge/uberon-bridge-to-bfo.owl
make bridge/uberon-bridge-to-caro.owl
cd $ROOT_DIR

cd cell-ontology/src/ontology
make cl-base.owl
cd $ROOT_DIR

cd obo-relations/src/ontology
make ro-base.owl
make other_import.owl
cd $ROOT_DIR

robot --catalog catalog-v001.xml \
  explain -i test-merged.ofn --reasoner ELK -M unsatisfiability --unsatisfiable random:1 --explanation unsat.md

LINES=`wc -l <unsat.md`
if [ $LINES -lt "2" ]
then
  exit 0
else
  cat unsat.md
  exit 1
fi
