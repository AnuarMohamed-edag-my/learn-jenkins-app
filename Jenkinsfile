pipeline {
    agent any

    // REMOVED the problematic 'environment' block here
    // The key is now calculated inside the 'script' block below

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies & Cache') {
            steps {
                script {
                    // 1. Calculate the dependency key using the AVAILABLE 'sha1' step
                    //    and the RELATIVE path to the lock file.
                    def lockFileHash = sha1(file: 'package-lock.json')
                    def cacheKey = "npm-deps-${env.JOB_NAME}-${lockFileHash}"
                    
                    echo "Calculated Cache Key: ${cacheKey}"
                    
                    // 2. Use the cache step with the dynamically generated key
                    //    'npm ci' runs ONLY if the cache is missed.
                    cache(path: 'node_modules', key: cacheKey) {
                        echo 'Installing/Restoring dependencies...'
                        sh 'npm ci' 
                    }
                }
            }
        }

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
                    ls -la
                '''
            }
        }

        // --- NEW STAGE: Parallel Testing ---
        stage('Tests'){
            parallel{ 
                
                /*Stage 2: Unit Test*/
                stage('Unit Test'){
                    agent {
                        docker{
                            image 'node:18-alpine' 
                            reuseNode true 
                        }
                    }
                    steps{
                        sh '''
                            test -f build/index.html
                            npm test
                        '''
                    }
                    post{
                        always{
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                /*Stage 3: E2E*/
                stage('E2E'){
                    agent {
                        docker{
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
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
                    post{
                        always{
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }
    }
}