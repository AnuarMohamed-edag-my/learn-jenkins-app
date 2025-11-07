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
            // Checksum calculates a unique hash of the file. 
            // If package-lock.json hasn't changed, the cache is reused!
            def cacheKey = "node-deps-${checksum('package-lock.json')}"
            
            // 1. Dependency Caching: This is the biggest speed-up
            cache(path: 'node_modules', key: cacheKey) {
                
                // --- COMMANDS INSIDE THE CACHING BLOCK ---
                sh '''
                    echo "Checking environment versions..."
                    node --version 
                    npm --version
                    
                    echo "Installing dependencies..."
                    # npm ci will run instantly if 'node_modules' was restored from cache.
                    # Otherwise, it runs a clean install.
                    npm ci
                '''
            }
            // --- COMMANDS OUTSIDE THE CACHING BLOCK ---
            
            // 2. Build Execution: This step relies on the dependencies being installed
            sh '''
                echo "Starting application build..."
                npm run build
                
                # Use ls -la only if you need to debug the resulting 'build' or 'dist' directory
                # ls -la 
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
