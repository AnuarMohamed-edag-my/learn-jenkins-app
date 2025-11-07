pipeline {
    agent any

    stages {
        /*Stage 1*/
        stage('Build') {
            agent {
                docker{
                    image 'node:18-alpine' //pull node.js -> 18-alpine image
                    reuseNode true         //tells the build tool to reuse an existing image layer or artifact from a previous stage
                                           //rather than re-running the installation
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
        /*Stage 2*/
        stage('Test'){
            agent {
                docker{
                    image 'node:18-alpine' //pull node.js -> 18-alpine image
                    reuseNode true         //tells the build tool to reuse an existing image layer or artifact from a previous stage
                                           //rather than re-running the installation
                }
            }
            steps{
                sh '''
                    test -f build/index.html
                    npm test
                '''
            }
        }
    }
}
