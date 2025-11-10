pipeline {
    agent any

    stages {
        /*Check Cache*/
        stage('Checkout & Install'){
            steps{
                checkout scm
                script{
                    // Requires Pipeline Utility Steps Plugin
                    def lockFileHash = sha1(file: 'package-lock.json') 
                    def cacheKey = "npm-deps-${env.JOB_NAME}-${lockFileHash}"
                    
                    cache(path: 'node_modules', key: cacheKey) {
                        // This runs ONLY if the lock file has changed (cache miss)
                        sh 'npm ci'
                }
            }
        }
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
                    #ls -la
                    #node --version 
                    #npm --version
                    #npm ci
                    npm run build
                    #ls -la
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
                    /*Post*/
                    post{
                        always{
                            junit 'jest-results/junit.xml'
                        }
                    }
                }//stage 2 end 

                /*Stage 3*/
                stage('E2E'){
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
                    /*Post*/
                    post{
                        always{
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }//stage 3 end 
            }//parallel
        }
    }//End Stage
}
