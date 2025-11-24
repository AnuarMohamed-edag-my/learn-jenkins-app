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
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }//end Parallel Stage
        stage('Deploy'){
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps{
                sh'''
                    NETLIFY_CLI="./node_modules/.bin/netlify"
                    
                    # Use 'test -x' to check if the executable file exists at the expected path
                    if [ ! -x "$NETLIFY_CLI" ]; then
                        echo "Netlify CLI not found locally. Installing..."
                        npm install netlify-cli@20.1.1
                    else
                        echo "Netlify CLI found locally, skipping npm install."
                    fi

                    # Deployment steps using the local executable
                    $NETLIFY_CLI --version
                    echo "Deploying to Production. Site ID: $NETLIFY_SITE_ID"
                    $NETLIFY_CLI status
                    $NETLIFY_CLI deploy --dir=build --prod --message="Deploy To Production"
                '''
            }
        }
    }//end of Stages 
}
