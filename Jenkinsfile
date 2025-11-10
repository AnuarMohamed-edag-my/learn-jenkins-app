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
                script{
                    // 1. Define the unique key based on the lock file
                    def cacheKey = "node-deps-${checksum('package-lock.json')}"
                    // 2. Wrap the installation in the 'cache' block
                    cache(path: 'node_modules', key : cacheKey){
                        // This block executes ONLY if the cache misses (first run, or lock file changed)
                        sh '''
                            echo "Cache Miss or Initial Run: Installing all dependencies..."
                            npm ci
                        '''
                    }
                    // 3. The build step always runs (using the restored/new node_modules)
                    sh '''
                        echo "Dependencies ready. Running build..."
                        npm run build
                        ls -la
                    '''

                }
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

    }

    /*Post*/
    post{
        always{
            junit 'jest-results/junit.xml'
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])

        }
    }
}
