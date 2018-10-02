ROBOT_ENV=ROBOT_JAVA_ARGS=-Xmx50G
ROBOT=$(ROBOT_ENV) robot
NCIT_UTILS_ENV=JAVA_OPTS=-Xmx50G
NCIT_UTILS=$(NCIT_UTILS_ENV) ncit-utils

all: properties-redundant.ttl
	

mirror: ontologies.ofn
	rm -rf $@ &&\
	$(ROBOT) mirror -i $< -d $@ -o $@/catalog-v001.xml

ontologies-merged.ttl: ontologies.ofn mirror
	$(ROBOT) merge --catalog mirror/catalog-v001.xml --include-annotations true -i $< \
	reason -r ELK -o $@

properties-nonredundant.ttl: ontologies-merged.ttl
	$(NCIT_UTILS) materialize-property-expressions ontologies-merged.ttl nonredundant=properties-nonredundant.ttl redundant=properties-redundant.ttl &&\
	touch properties-redundant.ttl

properties-redundant.ttl: properties-nonredundant.ttl
