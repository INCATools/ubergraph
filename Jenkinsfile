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
                    sh 'make -j 4 all'
             }
         }
     }
 }
