ROBOT_ENV=ROBOT_JAVA_ARGS=-Xmx50G
ROBOT=$(ROBOT_ENV) robot
NCIT_UTILS_ENV=JAVA_OPTS=-Xmx50G
NCIT_UTILS=$(NCIT_UTILS_ENV) ncit-utils
BG_RUNNER=JAVA_OPTS=-Xmx50G blazegraph-runner

all: ubergraph.jnl

mirror: ontologies.ofn
	rm -rf $@ &&\
	$(ROBOT) mirror -i $< -d $@ -o $@/catalog-v001.xml

ontologies-merged.ttl: ontologies.ofn mirror efo-base.ttl
	$(ROBOT) merge --catalog mirror/catalog-v001.xml --include-annotations true -i $< -i efo-base.ttl -i ubergraph-axioms.ofn \
	remove --axioms 'disjoint' --trim true --preserve-structure false \
	remove --term 'owl:Nothing' --trim true --preserve-structure false \
	reason -r ELK -D debug.ofn -o $@

efo.owl:
	curl -L -O 'http://www.ebi.ac.uk/efo/efo.owl'

efo-base.ttl: efo.owl
	$(ROBOT) remove --input $< \
		--base-iri 'http://www.ebi.ac.uk/efo/EFO_' \
		--axioms external \
		--preserve-structure false \
		--trim false \
		--output $@

subclass_closure.ttl: ontologies-merged.ttl subclass_closure.rq
	$(ROBOT) query -i $< --construct subclass_closure.rq $@

is_defined_by.ttl: ontologies-merged.ttl
	$(ROBOT) query -i $< --construct isDefinedBy.rq $@

properties-nonredundant.ttl: ontologies-merged.ttl
	$(NCIT_UTILS) materialize-property-expressions ontologies-merged.ttl properties-nonredundant.ttl properties-redundant.ttl &&\
	touch properties-redundant.ttl

properties-redundant.ttl: properties-nonredundant.ttl

antonyms_HP.txt:
	curl -L https://raw.githubusercontent.com/Phenomics/phenopposites/master/opposites/antonyms_HP.txt -o $@

opposites.ttl: antonyms_HP.txt
	echo "@prefix HP: <http://purl.obolibrary.org/obo/HP_> ." >$@
	awk 'NR > 2 { print $$1, "<http://purl.obolibrary.org/obo/RO_0002604>", $$2, "."}; NR > 2 { print $$2, "<http://reasoner.renci.org/opposite_of>", $$1, "."; } ' antonyms_HP.txt >>$@

ubergraph.jnl: ontologies-merged.ttl subclass_closure.ttl is_defined_by.ttl properties-nonredundant.ttl properties-redundant.ttl opposites.ttl
	rm -f $@ &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' ontologies-merged.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' opposites.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology/closure' subclass_closure.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' is_defined_by.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/nonredundant' properties-nonredundant.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/redundant' properties-redundant.ttl
