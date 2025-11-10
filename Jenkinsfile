pipeline {
    agent any

    environment {
        // Define the cache key prefix based on your project name
        NPM_CACHE_KEY = "npm-deps-${env.JOB_NAME}-${checksum("/var/jenkins_home/workspace/learn-jenkns-app/package-lock.json")}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Install Dependencies & Cache') {
            // Use 'any' agent for checkout and caching, or a dedicated build agent if preferred
            steps {
                script {
                    // The cache step handles restoring dependencies if package-lock.json hasn't changed.
                    // If restored, it skips 'npm install'. If not, it saves the new node_modules.
                    cache(path: 'node_modules', key: "${NPM_CACHE_KEY}") {
                        echo 'Installing/Restoring dependencies...'
                        sh 'npm ci'
                    }
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
                    ls -la
                    node --version 
                    npm --version
                    #npm ci
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
