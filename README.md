# Ubergraph [![image](https://user-images.githubusercontent.com/112839/112872474-563aac00-90b8-11eb-8a53-2ca19672f2a4.png)](https://doi.org/10.5281/zenodo.4641309)

## Integrated OBO ontology triplestore

- Merged set of mutually referential [OBO](https://obofoundry.org) ontologies:
  - Uberon anatomy
  - Cell Ontology (CL)
  - Provisional Cell Ontology (PCL)
  - Gene Ontology (GO)
  - Biospatial Ontology (BSPO)
  - Phenotype and Trait Ontology (PATO)
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
  - Drosophila Anatomy Ontology (FBbt)
  - Food Ontology (FoodOn)
- Precomputed OWL classification (class hierarchy)
- Materialized “class relations” from existential property restrictions (in separate named graphs)
- Blazegraph RDF triplestore; SPARQL query interface


## Query

### SPARQL endpoint

- Service: `https://ubergraph.apps.renci.org/sparql`
- Query interface in YASGUI: https://api.triplydb.com/s/e5aK9EOKg

### grlc API

Example SPARQL queries are [included in the repo](https://github.com/INCATools/ubergraph/tree/master/sparql), and can be queried via an OpenAPI user interface at http://grlc.io/api/INCAtools/ubergraph/sparql/.

## Graph organization

The Ubergraph triplestore is organized into several named graphs.

- `http://reasoner.renci.org/ontology` — All the merged axioms from the input ontologies (logical axioms and annotation axioms), classified using `robot reason -r ELK`. Disjointness axioms are removed prior to reasoning. Include this graph if you want term labels.
   - This graph also includes:
     - Generated `rdfs:isDefinedBy` triples connecting ontology terms to their OBO namespace ontology IRI. For example, there is a triple `<http://purl.obolibrary.org/obo/FOO_0123456> rdfs:isDefinedBy <http://purl.obolibrary.org/obo/foo.owl>` for every term with OBO namespace "foo". Matching these triples is much faster than using `FILTER(STRSTARTS(STR(?term), "http://purl.obolibrary.org/obo/FOO_"))`.
     - Precomputed information content score for each ontology class, based on the count of terms related to a given term via `rdfs:subClassOf` and [`part of`](http://purl.obolibrary.org/obo/BFO_0000050). The scores are `xsd:decimal` values scaled from `0` to `100` (e.g., a very specific term with no subclasses). Use the predicate `http://reasoner.renci.org/vocab/normalizedInformationContent` to retrieve IC scores.
- `http://reasoner.renci.org/redundant` — The complete inference closure for all subclass and existential relations. This includes all transitive, reflexive subclass relations. Within this graph, all predicates with the exception of `rdfs:subClassOf` imply an OWL existential relationship. For example, the triple:
   - `CL:0000080 BFO:0000050 UBERON:0000179` ([circulating cell](http://purl.obolibrary.org/obo/CL_0000080) • [part of](http://purl.obolibrary.org/obo/BFO_0000050) • [haemolymphatic fluid](http://purl.obolibrary.org/obo/UBERON_0000179))
   
   is shorthand for the OWL axiom
  
   - [circulating cell](http://purl.obolibrary.org/obo/CL_0000080) SubClassOf ([part of](http://purl.obolibrary.org/obo/BFO_0000050) some [haemolymphatic fluid](http://purl.obolibrary.org/obo/UBERON_0000179))
- `http://reasoner.renci.org/nonredundant` — Triples in this graph are a subset of, and have the same semantics as, the "redundant" graph, pruned according to several [redundancy rules](https://github.com/INCATools/ubergraph/blob/ef402ead9ec4e81d9cd998c833123ef48134bb2c/prune.dl#L29-L33).
- `https://biolink.github.io/biolink-model/` — RDF rendering of the [Biolink model](https://github.com/biolink/biolink-model), as well as triples connecting ontology terms to Biolink categories (derived from mappings in Biolink model), using the predicate `https://w3id.org/biolink/vocab/category`.
- `http://reasoner.renci.org/ontology/closure` — The transitive reflexive subclass closure only, no existential relations. _This graph may be removed, since these triples are all in `http://reasoner.renci.org/redundant`._

## Downloads

You can download files pertaining to the current build. Currently only the Blazegraph database file is available, but more are coming soon (e.g., N-Quads RDF).

- [Blazegraph database file](https://ubergraph.apps.renci.org/downloads/current/ubergraph.jnl.gz)

## Coherency checks

[![Coherency check](https://github.com/INCATools/ubergraph/actions/workflows/test-merged.yaml/badge.svg)](https://github.com/INCATools/ubergraph/actions/workflows/test-merged.yaml)

This repository includes a CI check to provide early warning for incompatibilites between some of the most tightly coupled ontologies. In this GitHub action, the ontologies are built from the latest source and checked for unsatisfiable classes.

## Support
Development of Ubergraph has been supported by the [NCATS Biomedical Data Translator project](https://github.com/NCATSTranslator), as well as by [RENCI](https://renci.org).
