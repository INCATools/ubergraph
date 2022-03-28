PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX linkml: <https://w3id.org/linkml/>
PREFIX biolink: <https://w3id.org/biolink/vocab/>

INSERT {
  GRAPH <https://biolink.github.io/biolink-model/> {
    ?term biolink:category ?blcategory
  }
}
WHERE {
  VALUES ?linkml_type { linkml:ClassDefinition linkml:SlotDefinition }
  ?category rdf:type ?linkml_type .
  ?category skos:mappingRelation|skos:exactMatch|skos:narrowMatch ?mapped .
  ?category (linkml:is_a|linkml:mixins)* ?blcategory .
  ?term rdfs:subClassOf* ?mapped .
}
