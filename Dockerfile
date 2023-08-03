FROM obolibrary/odkfull:v1.4.1

# Install tools provided by Ubuntu.
#RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get install -y --no-install-recommends \
#    graphviz \
#    nodejs \
#    npm

###### Souffle ######
#RUN curl -s https://packagecloud.io/install/repositories/souffle-lang/souffle/script.deb.sh | bash && apt-get install -y souffle

###### oxigraph ######
ENV OXIGRAPH=0.3.18
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=x86_64; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=x86_64; fi \
&& wget -nv https://github.com/oxigraph/oxigraph/releases/download/v$OXIGRAPH/oxigraph_server_v${OXIGRAPH}_${ARCHITECTURE}_linux_gnu \
&& mv oxigraph_server_v${OXIGRAPH}_${ARCHITECTURE}_linux_gnu /tools/oxigraph_server

###### blazegraph-runner #####
ENV BR=1.7
ENV PATH "/tools/blazegraph-runner/bin:$PATH"
RUN wget -nv https://github.com/balhoff/blazegraph-runner/releases/download/v$BR/blazegraph-runner-$BR.tgz \
&& tar -zxvf blazegraph-runner-$BR.tgz \
&& mv blazegraph-runner-$BR /tools/blazegraph-runner

###### relation-graph #####
#ENV RG=2.3.1
#ENV PATH "/tools/relation-graph/bin:$PATH"
#RUN wget -nv https://github.com/balhoff/relation-graph/releases/download/v$RG/relation-graph-cli-$RG.tgz \
#&& tar -zxvf relation-graph-cli-$RG.tgz \
#&& mv relation-graph-cli-$RG /tools/relation-graph

###### rdf-to-table #####
ENV RTT=0.1
ENV PATH "/tools/rdf-to-table/bin:$PATH"
RUN wget -nv https://github.com/balhoff/rdf-to-table/releases/download/v$RTT/rdf-to-table-$RTT.tgz \
&& tar -zxvf rdf-to-table-$RTT.tgz \
&& mv rdf-to-table-$RTT /tools/rdf-to-table

###### obographviz #####
#RUN cd /tools \
#&& git clone 'https://github.com/cmungall/obographviz.git' \
#&& cd obographviz \
#&& git checkout b0d8f64517d4ae0085072866aaadb7602f41acf7 \
#&& make install
#ENV PATH "/tools/obographviz/bin:$PATH"
