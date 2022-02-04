ROBOT_ENV=ROBOT_JAVA_ARGS=-Xmx120G
ROBOT=$(ROBOT_ENV) robot
RG_ENV=JAVA_OPTS=-Xmx120G
RG=$(RG_ENV) relation-graph
BG_RUNNER=JAVA_OPTS=-Xmx50G blazegraph-runner
JVM_ARGS=JVM_ARGS=-Xmx120G
ARQ=$(JVM_ARGS) arq
BIOLINK=2.2.4

ONTOLOGIES := $(shell cat "ontologies.txt")

all: ubergraph.jnl

mirror: ontologies.txt pr-base.owl ubergraph-axioms.ofn
	mkdir -p $@ && cd $@ &&\
	xargs -n 1 curl --retry 5 -L -O <../ontologies.txt &&\
	cp ../pr-base.owl pr-base.owl &&\
	$(ROBOT) convert -i ../ubergraph-axioms.ofn -o ubergraph-axioms.owl

pro_nonreasoned.obo:
	curl -L -O 'https://proconsortium.org/download/current/pro_nonreasoned.obo'

pr-base.owl: pro_nonreasoned.obo
	$(ROBOT) remove --input $< \
		--base-iri 'http://purl.obolibrary.org/obo/PR_' \
		--axioms external \
		--preserve-structure false \
		--trim false \
		--output $@

ontologies-merged.ttl: mirror
	$(ROBOT) merge $(addprefix -i mirror/,$(shell ls mirror)) \
	remove --axioms 'disjoint' --trim true --preserve-structure false \
	remove --term 'owl:Nothing' --trim true --preserve-structure false \
	reason -r ELK -D debug.ofn -o $@

subclass_closure.ttl: ontologies-merged.ttl subclass_closure.rq
	$(ARQ) -q --data=$< --query=subclass_closure.rq --results=ttl --optimize=off >$@

is_defined_by.ttl: ontologies-merged.ttl isDefinedBy.rq
	$(ARQ) -q --data=$< --query=isDefinedBy.rq --results=ttl >$@

properties-redundant.nt: ontologies-merged.ttl
	$(RG) --ontology-file $< --output-subclasses true --output-file $@

rdf.facts: properties-redundant.nt
	sed 's/ /\t/' <$< | sed 's/ /\t/' | sed 's/ \.$$//' >$@

ontrdf.facts: ontologies-merged.ttl
	riot --output=ntriples $< | sed 's/ /\t/' | sed 's/ /\t/' | sed 's/ \.$$//' >$@

properties-nonredundant.nt: rdf.facts ontrdf.facts prune.dl
	souffle -c prune.dl && mv nonredundant.csv $@

functors.o: functors.cpp
	g++ functors.cpp -c -fPIC -o functors.o

libfunctors.so: functors.o
	g++ -shared -o libfunctors.so functors.o

information-content.ttl: rdf.facts libfunctors.so ic.dl
	souffle -l functors -c ic.dl &&\
	awk -v FS='\t' -v OFS='\t' '{ print $$1, $$2, "\""$$3"\"^^<http://www.w3.org/2001/XMLSchema#decimal>", $$4}' icRDF.csv >$@.tmp &&\
	cat scRDF.csv >>$@.tmp && mv $@.tmp $@

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
# The conversion back to turtle works around a problem with Blazegraph parsing on Java 11
# We need to filter out dateTime values because these are badly formatted in biolink and cause riot to have non-zero exit code
# https://github.com/linkml/linkml/issues/253
biolink-model.ttl:
	curl -L 'https://raw.githubusercontent.com/biolink/biolink-model/$(BIOLINK)/biolink-model.ttl' -o $@.tmp
	riot --syntax=turtle --output=ntriples $@.tmp |\
	sed -E 's/<https:\/\/w3id.org\/biolink\/vocab\/([^[:space:]][^[:space:]]*):/<http:\/\/purl.obolibrary.org\/obo\/\1_/g' |\
	grep -v 'http://www.w3.org/2001/XMLSchema#dateTime' |\
	grep -v 'xsd:dateTime' |\
	riot --syntax=ntriples --output=turtle >$@

ubergraph.jnl: ontologies-merged.ttl subclass_closure.ttl is_defined_by.ttl properties-nonredundant.nt properties-redundant.nt opposites.ttl lexically-derived-opposites.nt lexically-derived-opposites-inverse.nt biolink-model.ttl sparql/biolink-categories.ru information-content.ttl
	rm -f $@ &&\
	$(BG_RUNNER) load --journal=$@ --informat=rdfxml --use-ontology-graph=true mirror &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' ontologies-merged.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' opposites.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' lexically-derived-opposites.nt &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' lexically-derived-opposites-inverse.nt &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='https://biolink.github.io/biolink-model/' biolink-model.ttl &&\
	$(BG_RUNNER) update --journal=$@ sparql/biolink-categories.ru
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology/closure' subclass_closure.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' is_defined_by.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' information-content.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/nonredundant' properties-nonredundant.nt &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/redundant' properties-redundant.nt

kgx/nodes.tsv: ubergraph.jnl sparql/kgx-nodes.rq
	mkdir -p kgx
	$(BG_RUNNER) select --journal=$< --outformat=tsv sparql/kgx-nodes.rq kgx/nodes.tsv
	$(BG_RUNNER) select --journal=$< --outformat=tsv sparql/kgx-edges.rq kgx/edges.tsv

kgx/edges.tsv: kgx/nodes.tsv


################################################
#### Commands for building the Docker image ####
################################################

VERSION = "1.1"
IM=monarchinitiative/ubergraph

docker-build-no-cache:
	@docker build --no-cache -t $(IM):$(VERSION) . \
	&& docker tag $(IM):$(VERSION) $(IM):latest

docker-build:
	@docker build -t $(IM):$(VERSION) . \
	&& docker tag $(IM):$(VERSION) $(IM):latest

docker-build-use-cache-dev:
	@docker build -t $(DEV):$(VERSION) . \
	&& docker tag $(DEV):$(VERSION) $(DEV):latest

docker-clean:
	docker kill $(IM) || echo not running ;
	docker rm $(IM) || echo not made 

docker-publish-no-build:
	@docker push $(IM):$(VERSION) \
	&& docker push $(IM):latest

docker-publish-dev-no-build:
	@docker push $(DEV):$(VERSION) \
	&& docker push $(DEV):latest

docker-publish: docker-build
	@docker push $(IM):$(VERSION) \
	&& docker push $(IM):latest
