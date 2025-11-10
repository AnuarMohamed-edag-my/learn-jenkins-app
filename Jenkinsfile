pipeline {
    agent any

    environment {
        // Define the cache key prefix based on your project name
        NPM_CACHE_KEY = "npm-deps-${env.JOB_NAME}-${checksum("package-lock.json")}"
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
                        sh 'npm install'
                    }
                }
            }
        }

        // --- STAGE 1: Build ---
        stage('Build') {
            agent {
                docker {
                    // Pull a clean, specific Node image
                    image 'node:18-alpine'
                    // Ensure the workspace (with cached node_modules) is mounted to the container
                    reuseNode true 
                }
            }
            steps {
                sh '''
                    echo "Running build inside Docker container..."
                    node --version 
                    npm --version
                    
                    # Dependencies are already installed/cached in the workspace, so skip re-installing:
                    # npm ci 
                    
                    npm run build
                    ls -la build 
                '''
            }
        }

        // --- NEW STAGE: Parallel Testing ---
        stage('Tests') {
            parallel {
                
                // --- STAGE 2: Unit Test ---
                stage('Unit Test') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            # Quick check to ensure build artifact exists before testing
                            test -f build/index.html || { echo "Build artifact missing. Exiting Unit Tests."; exit 1; }
                            npm test
                        '''
                    }
                    post {
                        always {
                            // Ensure the 'junit' step points to the correct test report file
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                // --- STAGE 3: E2E Test (with Playwright) ---
                stage('E2E') {
                    agent {
                        docker {
                            // Use a dedicated Playwright image with browsers pre-installed
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            # Install 'serve' locally, then start it in the background
                            npm install serve 
                            
                            # Start the built application on port 3000 (default for 'serve')
                            node_modules/.bin/serve -s build -l 3000 & 
                            SERVER_PID=$!
                            
                            # Use 'wait-for-it' or a similar tool for a reliable wait, 
                            # but a brief sleep is used here for simplicity. 
                            # For better speed: replace 'sleep 10' with a 'wait-for-port' script.
                            echo "Waiting 10 seconds for the server to start..."
                            sleep 10
                            
                            npx playwright test --reporter=html
                            
                            # Cleanup the background process
                            kill $SERVER_PID
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false, 
                                alwaysLinkToLastBuild: false, 
                                keepAll: false, 
                                reportDir: 'playwright-report', 
                                reportFiles: 'index.html', 
                                reportName: 'Playwright HTML Report', 
                                reportTitles: 'E2E Report', 
                                useWrapperFileDirectly: true
                            ])
                        }
                    }
                }
            } // parallel end
        }
    } // stages end
}