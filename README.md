# Ubergraph [![image](https://user-images.githubusercontent.com/112839/112872474-563aac00-90b8-11eb-8a53-2ca19672f2a4.png)](https://doi.org/10.5281/zenodo.4641309)

## Integrated OBO ontology triplestore

- Merged set of mutually referential OBO ontologies:
  - Uberon anatomy
  - Cell Ontology (CL)
  - Gene Ontology (GO)
  - Biospatial Ontology (BSPO)
  - Phenotype and Trait Ontology (PATO)
  - Human Phenotype Ontology (HPO)
  - Monarch Disease Ontology (MONDO)
  - Chemical Entities of Biological Interest (ChEBI)
  - Relations Ontology (RO)
  - Environmental conditions, treatments and exposures ontology (ECTO)
  - Environment Ontology (ENVO)
  - Ontology for Biomedical Investigations (OBI)
  - Medical Action Ontology (MAXO)
  - Evidence and Conclusion Ontology (ECO)
  - NCBI Taxonomy (slim version)
  - Experimental Factor Ontology (EFO)
  - Protein Ontology (PRO)
  - NCIt OBO Edition (NCIT)
- Precomputed OWL classification (class hierarchy)
- Materialized “class relations” from existential property restrictions (in separate named graphs)
- Blazegraph RDF triplestore; SPARQL query interface


## Query

SPARQL endpoint: `https://stars-app.renci.org/ubergraph/sparql`
- Query interface in YASGUI: https://api.triplydb.com/s/_26lcKdBY

## Graph organization

The Ubergraph triplestore is organized into several named graphs.

- `http://reasoner.renci.org/ontology` — All the merged axioms from the input ontologies (logical axioms and annotation axioms), classified using `robot reason -r ELK`. Disjointness axioms are removed prior to reasoning. Include this graph if you want term labels.
- `http://reasoner.renci.org/redundant` — The complete inference closure for all subclass and existential relations. This includes all transitive, reflexive subclass relations. Within this graph, all predicates with the exception of `rdfs:subClassOf` imply an OWL existential relationship. For example, the triple:
   - `CL:0000080 BFO:0000050 UBERON:0000179` ([circulating cell](http://purl.obolibrary.org/obo/CL_0000080) • [part of](http://purl.obolibrary.org/obo/BFO_0000050) • [haemolymphatic fluid](http://purl.obolibrary.org/obo/UBERON_0000179))
   
   is shorthand for the OWL axiom
  
   - [circulating cell](http://purl.obolibrary.org/obo/CL_0000080) SubClassOf ([part of](http://purl.obolibrary.org/obo/BFO_0000050) some [haemolymphatic fluid](http://purl.obolibrary.org/obo/UBERON_0000179))
- `http://reasoner.renci.org/nonredundant` — Triples in this graph are a subset of, and have the same semantics, as the "redundant" graph, pruned according to several [redundancy rules](https://github.com/INCATools/ubergraph/blob/ef402ead9ec4e81d9cd998c833123ef48134bb2c/prune.dl#L29-L33).
- `https://biolink.github.io/biolink-model/` — RDF rendering of the [Biolink model](https://github.com/biolink/biolink-model), as well as triples connecting ontology terms to Biolink categories (derived from mappings in Biolink model).
- `http://reasoner.renci.org/ontology/closure` — The transitive reflexive subclass closure only, no existential relations (may be removed).

## Support
Development of Ubergraph has been supported by the [NCATS Biomedical Data Translator project](https://github.com/NCATSTranslator), as well as by [RENCI](https://renci.org).
