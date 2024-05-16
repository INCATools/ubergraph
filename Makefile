ROBOT_ENV=ROBOT_JAVA_ARGS="-Xmx180G -XX:+UseParallelGC"
ROBOT=$(ROBOT_ENV) robot
RG_ENV=JAVA_OPTS="-Xmx180G -XX:+UseParallelGC"
RG=$(RG_ENV) relation-graph
BG_RUNNER=JAVA_OPTS="-Xmx80G -XX:+UseParallelGC" blazegraph-runner
JVM_ARGS=JVM_ARGS="-Xmx180G -XX:+UseParallelGC"
ARQ=$(JVM_ARGS) arq
RIOT=$(JVM_ARGS) riot
BIOLINK=3.0.0

NONBASE_ONTOLOGIES := $(shell cat "ontologies.txt")

all: ubergraph.jnl.gz ubergraph.nq.gz redundant-graph-table.tgz nonredundant-graph-table.tgz ontologies-merged.ofn.gz #ubergraph-oxigraph.tgz

mirror: ontologies.txt pr-base.owl po-base.owl ppo-base.owl apo-base.owl mmusdv-base.owl foodon-base.owl to-base.owl peco-base.owl mro-base.owl hao-base.owl clao-base.owl oarcs-base.owl ubergraph-axioms.ofn
	mkdir -p $@ && cd $@ &&\
	xargs -n 1 curl --retry 5 -L -O <../ontologies.txt &&\
	cp ../pr-base.owl pr-base.owl &&\
	cp ../po-base.owl po-base.owl &&\
	cp ../ppo-base.owl ppo-base.owl &&\
	cp ../apo-base.owl apo-base.owl &&\
	cp ../mmusdv-base.owl mmusdv-base.owl &&\
	cp ../foodon-base.owl foodon-base.owl &&\
	cp ../to-base.owl to-base.owl &&\
	cp ../peco-base.owl peco-base.owl &&\
	cp ../mro-base.owl mro-base.owl &&\
	cp ../hao-base.owl hao-base.owl &&\
	cp ../clao-base.owl clao-base.owl &&\
	cp ../oarcs-base.owl oarcs-base.owl &&\
	$(ROBOT) convert -i ../ubergraph-axioms.ofn -o ubergraph-axioms.owl

build-metadata.nt: build-sparql/build-metadata.rq
	$(ARQ) -q --query=$< --results=ntriples >$@.tmp && mv $@.tmp $@

# Make pseudo-base version for ontologies that don't provide one
# TODO add these all to a separate file instead of repeating code

pro_nonreasoned.owl.gz:
	curl -L -O 'https://proconsortium.org/download/current/pro_nonreasoned.owl.gz'

pr-base.owl: pro_nonreasoned.owl.gz
	$(ROBOT) remove --input $< \
		--base-iri 'http://purl.obolibrary.org/obo/PR_' \
		--axioms external \
		--preserve-structure false \
		--trim false \
		remove --select imports \
		--trim false \
		--output $@

ppo.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/ppo.owl'

ppo-base.owl: ppo.owl
	$(ROBOT) remove --input $< \
		--base-iri 'http://purl.obolibrary.org/obo/PPO_' \
		--axioms external \
		--preserve-structure false \
		--trim false \
		remove --select imports \
		--trim false \
		--output $@

po.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/po.owl'

po-base.owl: po.owl
	$(ROBOT) remove --input $< \
		--base-iri 'http://purl.obolibrary.org/obo/PO_' \
		--axioms external \
		--preserve-structure false \
		--trim false \
		remove --select imports \
		--trim false \
		--output $@

apo.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/apo.owl'

apo-base.owl: apo.owl
	$(ROBOT) remove --input $< \
		--base-iri 'http://purl.obolibrary.org/obo/APO_' \
		--axioms external \
		--preserve-structure false \
		--trim false \
		remove --select imports \
		--trim false \
		--output $@

mmusdv.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/mmusdv.owl'

mmusdv-base.owl: mmusdv.owl
	$(ROBOT) remove --input $< \
		--base-iri 'http://purl.obolibrary.org/obo/MmusDv_' \
		--axioms external \
		--preserve-structure false \
		--trim false \
		remove --select imports \
		--trim false \
		--output $@

foodon.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/foodon.owl'

foodon-base.owl: foodon.owl
	$(ROBOT) merge --input $< \
		remove \
			--base-iri 'http://purl.obolibrary.org/obo/FOODON_' \
			--axioms external \
			--preserve-structure false \
			--trim false \
			remove --select imports \
			--trim false \
			--output $@

to.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/to.owl'

to-base.owl: to.owl
	$(ROBOT) merge --input $< \
		remove \
			--base-iri 'http://purl.obolibrary.org/obo/TO_' \
			--axioms external \
			--preserve-structure false \
			--trim false \
			remove --select imports \
			--trim false \
			--output $@

peco.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/peco.owl'

peco-base.owl: peco.owl
	$(ROBOT) merge --input $< \
		remove \
			--base-iri 'http://purl.obolibrary.org/obo/PECO_' \
			--axioms external \
			--preserve-structure false \
			--trim false \
			remove --select imports \
			--trim false \
			--output $@

mro.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/mro.owl'

mro-base.owl: mro.owl
	$(ROBOT) merge --input $< \
		remove \
			--base-iri 'http://purl.obolibrary.org/obo/MRO_' \
			--axioms external \
			--preserve-structure false \
			--trim false \
			remove --select imports \
			--trim false \
			--output $@

hao.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/hao.owl'

hao-base.owl: hao.owl
	$(ROBOT) merge --input $< \
		remove \
			--base-iri 'http://purl.obolibrary.org/obo/HAO_' \
			--axioms external \
			--preserve-structure false \
			--trim false \
			remove --select imports \
			--trim false \
			--output $@

clao.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/clao.owl'

# CLAO provides a base download, but it includes RO axioms
clao-base.owl: clao.owl
	$(ROBOT) merge --input $< \
		remove \
			--base-iri 'http://purl.obolibrary.org/obo/CLAO_' \
			--axioms external \
			--preserve-structure false \
			--trim false \
			remove --select imports \
			--trim false \
			--output $@

oarcs.owl:
	curl -L -O 'http://purl.obolibrary.org/obo/oarcs.owl'

oarcs-base.owl: oarcs.owl
	$(ROBOT) merge --input $< \
		remove \
			--base-iri 'http://purl.obolibrary.org/obo/OARCS_' \
			--axioms external \
			--preserve-structure false \
			--trim false \
			remove --select imports \
			--trim false \
			--output $@

ontologies-merged.ttl: mirror
	$(ROBOT) merge $(addprefix -i mirror/,$(shell ls mirror)) \
	remove --axioms 'disjoint' --trim true --preserve-structure false \
	remove --term 'owl:Nothing' --trim true --preserve-structure false \
	query --update build-sparql/filter-bad-uri-values.ru \
	reason -r ELK -D debug.ofn -o $@.owl &&\
	$(RIOT) -q --nocheck --stream=turtle $@.owl >$@

ontologies-merged.ofn.gz: ontologies-merged.ttl
	$(ROBOT) convert -i $< -o ontologies-merged.ofn && gzip ontologies-merged.ofn

is_defined_by.ttl: ontologies-merged.ttl isDefinedBy.rq
	$(ARQ) -q --data=$< --query=isDefinedBy.rq --results=ttl >$@

properties-redundant.nt: ontologies-merged.ttl
	$(RG) --ontology-file $< --output-subclasses true --disable-owl-nothing true --output-file $@

rdf.facts: properties-redundant.nt
	sed 's/ /\t/' <$< | sed 's/ /\t/' | sed 's/ \.$$//' >$@

ontrdf.facts: ontologies-merged.ttl
	$(RIOT) -q --nocheck --output=ntriples $< | sed 's/ /\t/' | sed 's/ /\t/' | sed 's/ \.$$//' >$@

properties-nonredundant.nt: rdf.facts ontrdf.facts prune.dl
	souffle -c prune.dl && mv nonredundant.csv $@

functors.o: functors.cpp
	g++ functors.cpp -c -fPIC -o functors.o

libfunctors.so: functors.o
	g++ -shared -o libfunctors.so functors.o

information-content.ttl: rdf.facts libfunctors.so ic.dl
	souffle -l functors -c ic.dl &&\
	awk -v FS='\t' -v OFS='\t' '{ print $$1, $$2, "\""$$3"\"^^<http://www.w3.org/2001/XMLSchema#decimal>", $$4}' icRDF.csv >$@.tmp &&\
	awk -v FS='\t' -v OFS='\t' '{ print $$1, $$2, "\""$$3"\"^^<http://www.w3.org/2001/XMLSchema#decimal>", $$4}' subClassOfICRDF.csv >>$@.tmp &&\
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

obo_prefixes.ttl:
	curl -L -O 'http://purl.obolibrary.org/meta/obo_prefixes.ttl'

# This includes a hack to workaround JSON-LD context problems with biolink
# The conversion back to turtle works around a problem with Blazegraph parsing on Java 11
biolink-model.ttl:
	curl -L 'https://raw.githubusercontent.com/biolink/biolink-model/v$(BIOLINK)/biolink-model.ttl' -o $@.tmp
	riot -q --nocheck --syntax=turtle --output=ntriples $@.tmp |\
	sed -E 's/<https:\/\/w3id.org\/biolink\/vocab\/([^[:space:]][^[:space:]]*):/<http:\/\/purl.obolibrary.org\/obo\/\1_/g' |\
	riot -q --nocheck --syntax=ntriples --output=turtle >$@

ubergraph.jnl: build-metadata.nt ontologies-merged.ttl is_defined_by.ttl properties-nonredundant.nt properties-redundant.nt opposites.ttl lexically-derived-opposites.nt lexically-derived-opposites-inverse.nt biolink-model.ttl build-sparql/biolink-categories.ru information-content.ttl obo_prefixes.ttl
	rm -f $@ &&\
	$(BG_RUNNER) load --journal=$@ --informat=rdfxml --use-ontology-graph=true mirror &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' build-metadata.nt &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' ontologies-merged.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' opposites.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' obo_prefixes.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' lexically-derived-opposites.nt &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' lexically-derived-opposites-inverse.nt &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='https://biolink.github.io/biolink-model/' biolink-model.ttl &&\
	$(BG_RUNNER) update --journal=$@ build-sparql/biolink-categories.ru
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' is_defined_by.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/ontology' information-content.ttl &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/nonredundant' properties-nonredundant.nt &&\
	$(BG_RUNNER) load --journal=$@ --informat=turtle --graph='http://reasoner.renci.org/redundant' properties-redundant.nt

ubergraph.jnl.gz: ubergraph.jnl
	gzip --keep $<

ubergraph.nq.gz: ubergraph.jnl
	$(BG_RUNNER) dump --journal=$< --outformat=n-quads ubergraph.nq && gzip ubergraph.nq

redundant-graph-table.tgz: properties-redundant.nt build-metadata.nt
	mkdir -p redundant-graph-table &&\
	cp build-metadata.nt redundant-graph-table/build-metadata.nt &&\
	rdf-to-table --input-file $< --edges-file redundant-graph-table/edges.tsv --nodes-file redundant-graph-table/node-labels.tsv --predicates-file redundant-graph-table/edge-labels.tsv &&\
	tar -zcf $@ redundant-graph-table

nonredundant-graph-table.tgz: properties-nonredundant.nt build-metadata.nt
	mkdir -p nonredundant-graph-table &&\
	cp build-metadata.nt nonredundant-graph-table/build-metadata.nt &&\
	rdf-to-table --input-file $< --edges-file nonredundant-graph-table/edges.tsv --nodes-file nonredundant-graph-table/node-labels.tsv --predicates-file nonredundant-graph-table/edge-labels.tsv &&\
	tar -zcf $@ nonredundant-graph-table

ubergraph-tdb.tgz: ubergraph.nq.gz
	rm -rf ubergraph-tdb && mkdir ubergraph-tdb &&\
	tdb2.tdbloader --loc ubergraph-tdb $< &&\
	tdb2.tdbstats --loc ubergraph-tdb --graph urn:x-arq:UnionGraph >stats.opt &&\
	mv stats.opt ubergraph-tdb/Data-0001/stats.opt &&\
	tar -zcf $@ ubergraph-tdb

ubergraph-oxigraph.tgz: ubergraph.nq.gz
	rm -rf ubergraph-oxigraph && mkdir ubergraph-oxigraph &&\
	oxigraph_server --location ubergraph-oxigraph load --file $< &&\
	tar -zcf $@ ubergraph-oxigraph

kgx/nodes.tsv: ubergraph.jnl build-sparql/kgx-nodes.rq
	mkdir -p kgx
	$(BG_RUNNER) select --journal=$< --outformat=tsv build-sparql/kgx-nodes.rq kgx/nodes.tsv
	$(BG_RUNNER) select --journal=$< --outformat=tsv build-sparql/kgx-edges.rq kgx/edges.tsv

kgx/edges.tsv: kgx/nodes.tsv


################################################
#### Commands for building the Docker image ####
################################################

VERSION = "1.7"
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

docker-all:
	docker buildx build --platform linux/amd64,linux/arm64 --no-cache --push -t $(IM):$(VERSION) .
