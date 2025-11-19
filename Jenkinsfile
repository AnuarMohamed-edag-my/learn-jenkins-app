pipeline {
    agent any

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
                        else {
                            // 4. Cache Miss: Run installation and let the 'jobcacher' step save the result.
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

    }
}
