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
                script {
                    def cacheKey = "node-deps-${checksum('package-lock.json')}"

                    cache(path: 'node-modules', key: cacheKey){
                        sh '''
                            echo "Checking environment versions..."
                            node -v
                            npm -v

                            echo "Installing dependencies..."
                            npm ci
                        '''
                    }

                    sh '''
                       echo "Starting application build..."
                       npm run build
                       echo "Build Stage complete." 
                    '''
                }
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
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy' //pull playwright image
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
