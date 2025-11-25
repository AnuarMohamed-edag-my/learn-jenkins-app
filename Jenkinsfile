pipeline {
    agent any

    triggers{
        cron('0 3 * * 1-5')
        /*Git Polling*/
        pollSCM('* * * * *')
    }

    environment{
        NETLIFY_SITE_ID = '4e87976e-4e25-4c6a-98f6-ac732bb68953'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')

    }

    stages {
        stage('Checkout'){
            steps{
                checkout scm
            }
        }
        stage('Install Dependencies & Cache'){
            steps{
                script{
                    // 1. Calculate the dependency key using the available 'sha1' step
                    def lockFileHash = sha1(file: 'package-lock.json')
                    def cacheKey = "npm-deps-${env.JOB_NAME}-${lockFileHash}"
                    echo "Calculated Cache Key: ${cacheKey}"

                    // 2. Use the low-level 'jobcacher' step with 'includes' and 'key' 
                    //    This attempts to restore 'node_modules' based on the key.
                    jobcacher(cachingDisabled: false, includes: ['node_modules'], key: cacheKey) {
                        // 3. Conditional execution: Check if the cache was restored.
                        if (fileExists('node_modules')) {
                            echo 'Cache hit: Dependencies restored. Skipping npm ci. TAKPAYAH NAK NPM CI DAH......'
                        } 
                        // 4. Cache Miss: Run installation and let the 'jobcacher' step save the result.
                        else {
                            echo 'FILE NODE_MODULES TAKDE. SO NAK KENE INSTALL la.......'
                            echo 'Cache miss: Installing dependencies...'
                            sh'''
                                npm ci
                            '''
                        }
                    }
                }
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
                    npm run build 
                    ls -la 
                '''
            }
        }

        /*Parallel Testing Stages*/
        stage('Tests'){
            parallel{
                /*Stage 2: Test */
                stage('Unit Test') {
                    agent{
                        docker{
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
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
                /*Stage 3: End-to-End Test*/
                stage('E2E'){
                    agent {
                        docker{
                            /*Pull Playwright Image*/
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh'''
                            npm install serve 
                            node_modules/.bin/serve -s build & 
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post{
                        always{
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }//end Parallel Stage
        /*Stage 4: Deploy Staging*/
        stage('Deploy Staging'){
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps{
                sh'''
                    npm install netlify-cli@20.1.1
                    node_modules/.bin/netlify --version
                    echo "Deploying to Staging. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build  
                '''
            }
        }
        /*Stage 5: Deploy Prod*/
        stage('Deploy Prod.'){
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps{
                sh'''
                    npm install netlify-cli@20.1.1
                    node_modules/.bin/netlify --version
                    echo "Deploying to Production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod --message="Deploy To Production"
                '''
            }
        }
        /*Stage 6: Production E2E*/
        stage('Prod E2E'){
            agent {
                docker{
                    /*Pull Playwright Image*/
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            environment{
                CI_ENVIRONMENT_URL = 'https://traningjenkinsanuar.netlify.app'
            }
            steps {
                sh'''
                    npx playwright test --reporter=html
                '''
            }
            post{
                always{
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright E2E Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }//end of Stages 
}
