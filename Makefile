ROBOT_ENV=ROBOT_JAVA_ARGS=-Xmx120G
ROBOT=$(ROBOT_ENV) robot
RG_ENV=JAVA_OPTS=-Xmx120G
RG=$(RG_ENV) relation-graph
BG_RUNNER=JAVA_OPTS=-Xmx50G blazegraph-runner
JVM_ARGS=JVM_ARGS=-Xmx120G
ARQ=$(JVM_ARGS) arq
BIOLINK=2.1.0

all: ubergraph.jnl

mirror: ontologies.ofn
	rm -rf $@ &&\
	$(ROBOT) mirror -i $< -d $@ -o $@/catalog-v001.xml

pro_nonreasoned.obo:
	curl -L -O 'https://proconsortium.org/download/current/pro_nonreasoned.obo'

pr-base.ttl: pro_nonreasoned.obo
	$(ROBOT) remove --input $< \
		--base-iri 'http://purl.obolibrary.org/obo/PR_' \
		--axioms external \
		--preserve-structure false \
		--trim false \
		--output $@

ontologies-merged.ttl: ontologies.ofn mirror pr-base.ttl
	$(ROBOT) merge --catalog mirror/catalog-v001.xml --include-annotations true -i $< -i pr-base.ttl -i ubergraph-axioms.ofn \
	remove --axioms 'disjoint' --trim true --preserve-structure false \
	remove --term 'owl:Nothing' --trim true --preserve-structure false \
	reason -r ELK -D debug.ofn -o $@

subclass_closure.ttl: ontologies-merged.ttl subclass_closure.rq
	$(ARQ) -q --data=$< --query=subclass_closure.rq --results=ttl --optimize=off >$@

is_defined_by.ttl: ontologies-merged.ttl isDefinedBy.rq
	$(ARQ) -q --data=$< --query=isDefinedBy.rq --results=ttl >$@

properties-nonredundant.ttl: ontologies-merged.ttl
	$(RG) --ontology-file ontologies-merged.ttl --non-redundant-output-file properties-nonredundant.ttl --redundant-output-file properties-redundant.ttl &&\
	touch properties-redundant.ttl

properties-redundant.ttl: properties-nonredundant.ttl

antonyms_HP.txt:
	curl -L https://raw.githubusercontent.com/Phenomics/phenopposites/master/opposites/antonyms_HP.txt -o $@

lexically-derived-opposites.nt:
	curl -L "https://raw.githubusercontent.com/NCATSTranslator/opposites/main/assertions/results/lexically-derived-opposites/lexically-derived-opposites.nt" -o $@

lexically-derived-opposites-inverse.nt: lexically-derived-opposites.nt
	awk '{ print $$3, $$2, $$1, "."; } ' $< >$@

opposites.ttl: antonyms_HP.txt
	echo "@prefix HP: <http://purl.obolibrary.org/obo/HP_> ." >$@
	awk 'NR > 2 { print $$1, "<http://purl.obolibrary.org/obo/RO_0002604>", $$2, "."}; NR > 2 { print $$2, "<http://purl.obolibrary.org/obo/RO_0002604>", $$1, "."; } ' antonyms_HP.txt >>$@

# This includes a hack to workaround JSON-LD context problems with biolink
biolink-model.ttl:
	curl -L 'https://raw.githubusercontent.com/biolink/biolink-model/$(BIOLINK)/biolink-model.ttl' -o $@.tmp
	riot --syntax=turtle --output=ntriples $@.tmp | sed -E 's/<https:\/\/w3id.org\/biolink\/vocab\/([^[:space:]][^[:space:]]*):/<http:\/\/purl.obolibrary.org\/obo\/\1_/g' >$@

ubergraph.jnl: ontologies-merged.ttl subclass_closure.ttl is_defined_by.ttl properties-nonredundant.ttl properties-redundant.ttl opposites.ttl lexically-derived-opposites.nt lexically-derived-opposites-inverse.nt biolink-model.ttl
	rm -f $@ &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' ontologies-merged.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' opposites.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' lexically-derived-opposites.nt &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' lexically-derived-opposites-inverse.nt &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='https://biolink.github.io/biolink-model/' biolink-model.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology/closure' subclass_closure.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' is_defined_by.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/nonredundant' properties-nonredundant.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/redundant' properties-redundant.ttl

kgx/nodes.tsv: ubergraph.jnl sparql/kgx-nodes.rq
	mkdir -p kgx
	$(BG_RUNNER) select --journal=$< --outformat=tsv sparql/kgx-nodes.rq kgx/nodes.tsv
	$(BG_RUNNER) select --journal=$< --outformat=tsv sparql/kgx-edges.rq kgx/edges.tsv

kgx/edges.tsv: kgx/nodes.tsv
