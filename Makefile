ROBOT_ENV=ROBOT_JAVA_ARGS=-Xmx50G
ROBOT=$(ROBOT_ENV) robot
NCIT_UTILS_ENV=JAVA_OPTS=-Xmx50G
NCIT_UTILS=$(NCIT_UTILS_ENV) ncit-utils
BG_RUNNER=JAVA_OPTS=-Xmx50G blazegraph-runner

all: ubergraph.jnl

mirror: ontologies.ofn
	rm -rf $@ &&\
	$(ROBOT) mirror -i $< -d $@ -o $@/catalog-v001.xml

ontologies-merged.ttl: ontologies.ofn mirror
	$(ROBOT) merge --catalog mirror/catalog-v001.xml --include-annotations true -i $< \
	remove --axioms 'disjoint' --trim true \
	remove --term 'owl:Nothing' --trim true \
	reason -r ELK -D debug.ofn -o $@

subclass_closure.ttl: ontologies-merged.ttl subclass_closure.rq
	$(ROBOT) query -i $< --construct subclass_closure.rq $@

properties-nonredundant.ttl: ontologies-merged.ttl
	$(NCIT_UTILS) materialize-property-expressions ontologies-merged.ttl properties-nonredundant.ttl properties-redundant.ttl &&\
	touch properties-redundant.ttl

properties-redundant.ttl: properties-nonredundant.ttl

antonyms_HP.txt:
	curl -L https://raw.githubusercontent.com/Phenomics/phenopposites/master/opposites/antonyms_HP.txt -o $@

opposites.ttl: antonyms_HP.txt
	awk 'NR > 2 { print $1, "<http://reasoner.renci.org/opposite_of>", $2, "."}; NR > 2 { print $2, "<http://reasoner.renci.org/opposite_of>", $1, "."; } ' antonyms_HP.txt > $@

ubergraph.jnl: subclass_closure.ttl properties-nonredundant.ttl properties-redundant.ttl
	rm -f $@ &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' ontologies-merged.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' opposites.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology/closure' subclass_closure.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/nonredundant' properties-nonredundant.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/redundant' properties-redundant.ttl