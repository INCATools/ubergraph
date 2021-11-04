pipeline {
    agent {
        docker {
            image 'monarchinitiative/ubergraph'
            label 'zeppo'
        }
        triggers {
                cron('H 0 * * 5')
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
