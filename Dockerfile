FROM obolibrary/odkfull:v1.6

###### blazegraph-runner #####
ENV BR=1.7
ENV PATH "/tools/blazegraph-runner/bin:$PATH"
RUN wget -nv https://github.com/balhoff/blazegraph-runner/releases/download/v$BR/blazegraph-runner-$BR.tgz \
    && tar -zxvf blazegraph-runner-$BR.tgz \
    && mv blazegraph-runner-$BR /tools/blazegraph-runner

###### rdf-to-table #####
ENV RTT=0.1
ENV PATH "/tools/rdf-to-table/bin:$PATH"
RUN wget -nv https://github.com/balhoff/rdf-to-table/releases/download/v$RTT/rdf-to-table-$RTT.tgz \
    && tar -zxvf rdf-to-table-$RTT.tgz \
    && mv rdf-to-table-$RTT /tools/rdf-to-table
