FROM obolibrary/odkfull:v1.2.29

# Install tools provided by Ubuntu.
RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get install -y --no-install-recommends \
    graphviz \
    nodejs \
    npm

###### Souffle ######
RUN curl -s https://packagecloud.io/install/repositories/souffle-lang/souffle/script.deb.sh | bash && apt-get install -y souffle

###### blazegraph-runner #####
ENV BR=1.5
ENV PATH "/tools/blazegraph-runner/bin:$PATH"
RUN wget -nv https://github.com/balhoff/blazegraph-runner/releases/download/v$BR/blazegraph-runner-$BR.tgz \
&& tar -zxvf blazegraph-runner-$BR.tgz \
&& mv blazegraph-runner-$BR /tools/blazegraph-runner \
&& chmod +x /tools/blazegraph-runner

###### relation-graph #####
ENV RG=1.2.1
ENV PATH "/tools/relation-graph/bin:$PATH"
RUN wget -nv https://github.com/balhoff/relation-graph/releases/download/v$RG/relation-graph-$RG.tgz \
&& tar -zxvf relation-graph-$RG.tgz \
&& mv relation-graph-$RG /tools/relation-graph \
&& chmod +x /tools/relation-graph

###### obographviz #####
RUN cd /tools \
&& git clone 'https://github.com/cmungall/obographviz.git' \
&& cd obographviz \
&& git checkout b0d8f64517d4ae0085072866aaadb7602f41acf7 \
&& make install
ENV PATH "/tools/obographviz/bin:$PATH"
