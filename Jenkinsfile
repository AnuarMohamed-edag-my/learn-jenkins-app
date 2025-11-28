pipeline {
    // Defines where the pipeline will run
    agent any 

    // Environment variables for easy modification and clean shell scripts
    environment {
        // Name of the Docker image repository
        DOCKER_IMAGE_REPO = 'my-playwright' 
        // Name of the artifact file created inside the container
        TEST_ARTIFACT_FILENAME = 'test-results.txt' 
        // Full path to the artifact file inside the container
        TEST_ARTIFACT_PATH_IN_CONTAINER = '/var/jenkins_home/workspace/Anuar_Jenkins/test-results.txt' 
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Assuming Jenkins is set up to automatically checkout the SCM
                script {
                    echo "Checking out Git repository..."
                }
            }
        }

        stage('Build Test Runner & Extract Artifact') {
            steps {
                script {
                    def tempImageTag = "${DOCKER_IMAGE_REPO}-temp:${BUILD_NUMBER}"
                    
                    // 1. Build ONLY the 'test-runner' stage using the --target flag
                    echo "Building Docker image stage: test-runner"
                    sh "docker build --target test-runner -t ${tempImageTag} ."
                    
                    // 2. Run a temporary container and copy the artifact out
                    echo "Extracting ${TEST_ARTIFACT_FILENAME} from container..."
                    
                    // Use Groovy triple quotes for the multi-line shell command.
                    // -v ${WORKSPACE}:/mount maps the Jenkins directory to the container.
                    sh """
                        docker run --rm -v ${WORKSPACE}:/mount ${tempImageTag} sh -c "cp ${TEST_ARTIFACT_PATH_IN_CONTAINER} /mount/"
                    """
                    
                    // 3. Clean up the temporary image tag (optional, but recommended)
                    sh "docker rmi ${tempImageTag}"
                }
            }
        }

        stage('Archive Test Results') {
            steps {
                // Archives the file that was copied into the Jenkins workspace.
                echo "Archiving artifacts to Jenkins build record."
                archiveArtifacts artifacts: "${TEST_ARTIFACT_FILENAME}", onlyIfSuccessful: true
            }
        }
    }
}