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

        //NEW STAGE 
        stage('Tests'){
            parallel{ /*Run Stages in Parallel*/
                    /*Stage 2*/
                stage('Unit Test'){
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
                }//stage 2 end 
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
                            npx playwright test --reporter=html
                        '''
                    }
                }//stage 3 end 
            }//parallel
        }

    }

    /*Post*/
    post{
        always{
            junit 'jest-results/junit.xml'
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])

        }
    }
}
