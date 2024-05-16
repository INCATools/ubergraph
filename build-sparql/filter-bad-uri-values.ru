PREFIX term_tracker_item: <http://purl.obolibrary.org/obo/IAO_0000233>
DELETE {
  ?term term_tracker_item: ?value .
}
WHERE {
  ?term term_tracker_item: ?value .
  FILTER(!STRSTARTS(STR(?value), "http"))
}
