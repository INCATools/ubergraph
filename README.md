# ubergraph
Integrated OBO ontology store for Data Translator

- Merged set of mutually referential OBO ontologies
  - Uberon anatomy, Cell Ontology (CL), Gene Ontology (GO), Biospatial Ontology (BSPO), Phenotype and Trait Ontology (PATO), Human Phenotype Ontology (HPO), Monarch Disease Ontology (MONDO), Chemical Entities of Biological Interest (ChEBI), Relations Ontology (RO)
- Precomputed OWL classification (class hierarchy)
- Materialized “class relations” from existential property restrictions (in separate named graphs)
- Blazegraph RDF triplestore; SPARQL query interface

SPARQL endpoint: `https://stars-app.renci.org/uberongraph/sparql`
- Query interface in YASGUI: http://yasgui.org/short/4mSecFSEn
