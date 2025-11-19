pipeline {
    agent any
    // REMOVED the problematic 'environment' block here
    // The key is now calculated inside the 'script' block below
    stages {

        /*Stage 1: Build - Dependencies are now in the workspace*/
        stage('Build') {
            agent {
                docker{
                    image 'node:18-alpine'
                    reuseNode true 
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version 
                    npm --version
                    npm run build
                    npm ci
                    ls -la
                '''
                
            }
        }

    }
}
