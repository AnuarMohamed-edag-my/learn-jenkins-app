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
        /*Stage 3*/
        stage('End-to-End'){
            agent {
                docker{
                    image 'mcr.microsoft.com/playwright:v1.56.1-noble' //pull playwright image
                    reuseNode true
                }
            }
            steps{
                sh '''
                    npm install serve 
                    node_modules/.bin/serve -s build & 
                    sleep 10
                    npx playwright test
                '''
            }
        }
    }

    /*Post*/
    post{
        always{
            junit 'jest-results/junit.xml'
        }
    }
}
