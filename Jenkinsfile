pipeline {
    agent {
        docker {
            image 'monarchinitiative/ubergraph'
            label 'zeppo'
        }
    }
     stages {
         stage('Build') {
             steps {
                    sh "souffle --version"
                    sh "relation-graph --help"
                    sh 'make -j 4 all'
             }
         }
     }
 }
