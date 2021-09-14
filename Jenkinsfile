pipeline {
    agent {
        docker {
            image 'obolibrary/odkfull'
            label 'zeppo'
        }
    }
     stages {
         stage('Build') {
             steps {
                    sh "curl -s https://packagecloud.io/install/repositories/souffle-lang/souffle/script.deb.sh | sudo bash && sudo apt-get install -y souffle" 
                    sh "curl -L -O https://github.com/balhoff/blazegraph-runner/releases/download/v1.5/blazegraph-runner-1.5.tgz &&\
  tar -zxf blazegraph-runner-1.5.tgz && mv blazegraph-runner-1.5 blazegraph-runner"
                    sh "curl -L -O https://github.com/balhoff/relation-graph/releases/download/v1.2.1/relation-graph-1.2.1.tgz &&\
  tar -zxf relation-graph-1.2.1.tgz && mv relation-graph-1.2.1 relation-graph"
                    sh "curl -L -O http://archive.apache.org/dist/jena/binaries/apache-jena-3.12.0.tar.gz &&\
  tar -zxf apache-jena-3.12.0.tar.gz && mv apache-jena-3.12.0 apache-jena"
                    sh "export PATH=blazegraph-runner/bin:apache-jena/bin:relation-graph/bin:bin:/tools:$PATH"
                    sh "souffle --version"
                    sh "relation-graph --help"
                    sh 'make -j 4 all'
             }
         }
     }
 }
