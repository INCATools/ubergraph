# Ubergraph [![image](https://user-images.githubusercontent.com/112839/112872474-563aac00-90b8-11eb-8a53-2ca19672f2a4.png)](https://doi.org/10.5281/zenodo.4641309)

Ubergraph paper presented at ICBO 2022: https://doi.org/10.5281/zenodo.7249759

## Integrated OBO ontology triplestore

- Merged set of mutually referential [OBO](https://obofoundry.org) ontologies:
  - Uberon anatomy
  - Cell Ontology (CL)
  - Provisional Cell Ontology (PCL)
  - Gene Ontology (GO)
  - Biospatial Ontology (BSPO)
  - Phenotype and Trait Ontology (PATO)
  - Ontology of Biological Attributes (OBA)
  - Human Phenotype Ontology (HPO)
  - Mammalian Phenotype Ontology (MP)
  - Fission Yeast Phenotype Ontology (FYPO)
  - Monarch Disease Ontology (MONDO)
  - Chemical Entities of Biological Interest (ChEBI)
  - Relations Ontology (RO)
  - Environmental conditions, treatments and exposures ontology (ECTO)
  - Environment Ontology (ENVO)
  - Ontology for Biomedical Investigations (OBI)
  - Medical Action Ontology (MAXO)
  - Evidence and Conclusion Ontology (ECO)
  - NCBI Taxonomy
  - Protein Ontology (PRO)
  - NCIt OBO Edition (NCIT)
  - Plant Ontology (PO)
  - Plant Phenology Ontology (PPO)
  - Plant Trait Ontology (TO)
  - Plant Experimental Conditions Ontology (PECO)
  - Drosophila Anatomy Ontology (FBbt)
  - Food Ontology (FoodOn)
  - Population and Community Ontology (PCO)
  - Information Artifact Ontology (IAO)
  - Measurement Method Ontology (MMO)
  - Molecular Interactions Controlled Vocabulary (MI)
  - Sequence Ontology (SO)
  - C. elegans Gross Anatomy Ontology (WBbt)
  - C. elegans development ontology (WBls)
  - C. elegans phenotype (WBPhenotype)
  - Zebrafish anatomy and development ontology (ZFA)
  - Ascomycete phenotype ontology (APO)
  - Mouse Developmental Stages (MmusDV)
  - Human Developmental Stages (HsapDv)
  - Vertebrate Breed Ontology (VBO)
  - Units of Measurement Ontology (UO)
- Precomputed OWL classification (class hierarchy)
- Materialized “class relations” from existential property restrictions (in separate named graphs)
- Blazegraph RDF triplestore; SPARQL query interface

## Query

### SPARQL endpoint

- Service: `https://ubergraph.apps.renci.org/sparql`
- Query interface in YASGUI (this query retrieves the current build date): https://api.triplydb.com/s/oQgG4f0gs

### grlc API

Example SPARQL queries are [included in the repo](https://github.com/INCATools/ubergraph/tree/master/sparql), and can be queried via an OpenAPI user interface at https://grlc.io/api-git/INCATools/ubergraph/subdir/sparql.

## Graph organization

The Ubergraph triplestore is organized into several named graphs.

- `http://reasoner.renci.org/ontology` — All the merged axioms from the input ontologies (logical axioms and annotation axioms), classified using `robot reason -r ELK`. Disjointness axioms are removed prior to reasoning. Include this graph if you want term labels.
   - This graph also includes:
     - Generated `rdfs:isDefinedBy` triples connecting ontology terms to their OBO namespace ontology IRI. For example, there is a triple `<http://purl.obolibrary.org/obo/FOO_0123456> rdfs:isDefinedBy <http://purl.obolibrary.org/obo/foo.owl>` for every term with OBO namespace "foo". Matching these triples is much faster than using `FILTER(STRSTARTS(STR(?term), "http://purl.obolibrary.org/obo/FOO_"))`.
     - Precomputed information content score for each ontology class, based on the count of terms related to a given term via `rdfs:subClassOf` or any existential relation. The scores are `xsd:decimal` values scaled from `0` to `100` (e.g., a very specific term with no subclasses). Use the predicate `http://reasoner.renci.org/vocab/normalizedInformationContent` to retrieve IC scores.
- `http://reasoner.renci.org/redundant` — The complete inference closure for all subclass and existential relations. This includes all transitive, reflexive subclass relations. Within this graph, all predicates with the exception of `rdfs:subClassOf` imply an OWL existential relationship. For example, the triple:
   - `CL:0000080 BFO:0000050 UBERON:0000179` ([circulating cell](http://purl.obolibrary.org/obo/CL_0000080) • [part of](http://purl.obolibrary.org/obo/BFO_0000050) • [haemolymphatic fluid](http://purl.obolibrary.org/obo/UBERON_0000179))
   
   is shorthand for the OWL axiom
  
   - [circulating cell](http://purl.obolibrary.org/obo/CL_0000080) SubClassOf ([part of](http://purl.obolibrary.org/obo/BFO_0000050) some [haemolymphatic fluid](http://purl.obolibrary.org/obo/UBERON_0000179))
- `http://reasoner.renci.org/nonredundant` — Triples in this graph are a subset of, and have the same semantics as, the "redundant" graph, pruned according to several [redundancy rules](https://github.com/INCATools/ubergraph/blob/ef402ead9ec4e81d9cd998c833123ef48134bb2c/prune.dl#L29-L33).
- `https://biolink.github.io/biolink-model/` — RDF rendering of the [Biolink model](https://github.com/biolink/biolink-model), as well as triples connecting ontology terms to Biolink categories (derived from mappings in Biolink model), using the predicate `https://w3id.org/biolink/vocab/category`.

## Downloads

You can download files pertaining to the current build.

- [RDF N-Quads](https://ubergraph.apps.renci.org/downloads/current/ubergraph.nq.gz) (RDF four column format: subject, predicate, object, graph)
- [Blazegraph database file](https://ubergraph.apps.renci.org/downloads/current/ubergraph.jnl.gz)
- Redundant and nonredundant graphs as integer-based edge tables for graph analysis or machine-learning.
  - Archives contain these files:
    - `edges.tsv`: tab-separated subject, predicate, object integer IDs
    - `node-labels.tsv`: tab-separated node ID, node IRI (nodes are subjects and objects in the edges table)
    - `edge-labels.tsv`: tab-separated relation ID, relation IRI
    - `build-metadata.nt`: RDF describing Ubergraph build date
  - Available graphs:
    - [nonredundant-graph-table.tgz](https://ubergraph.apps.renci.org/downloads/current/nonredundant-graph-table.tgz)
    - [redundant-graph-table.tgz](https://ubergraph.apps.renci.org/downloads/current/redundant-graph-table.tgz)
## Coherency checks

[![Coherency check](https://github.com/INCATools/ubergraph/actions/workflows/test-merged.yaml/badge.svg)](https://github.com/INCATools/ubergraph/actions/workflows/test-merged.yaml)

This repository includes a CI check to provide early warning for incompatibilites between some of the most tightly coupled ontologies. In this GitHub action, the ontologies are built from the latest source and checked for unsatisfiable classes.

## Support
Development of Ubergraph has been supported by the [NCATS Biomedical Data Translator project](https://github.com/NCATSTranslator), as well as by [RENCI](https://renci.org).
