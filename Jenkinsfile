pipeline {
    agent any

    stages {
        stage('Checkout'){
            steps{
                checkout scm
            }
        }
        /*Stage 1: Build - Dependencies are now in the workspace*/
        stage('Build') {
            agent{
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
                    npm ci
                    npm run build 
                    ls -la 
                '''

            }
        }

    }
}
