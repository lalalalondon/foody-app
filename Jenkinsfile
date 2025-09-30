pipeline {
    agent any
    
    tools {
        maven 'Maven'
    }
    
    environment {
        MAVEN_OPTS = '-Dmaven.test.failure.ignore=true'
        DOCKER_IMAGE = 'foody-app'
        APP_NAME = 'foody-app'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building the application...'
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh 'mvn test'
            }
            post {
                always {
                    // Publish test results using junit
                    junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
                }
            }
        }
        
        stage('Package') {
            steps {
                echo 'Packaging the application...'
                sh 'mvn package -DskipTests'
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                echo 'Archiving build artifacts...'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh '''
                        # Build Docker image with the application
                        docker build -t ${DOCKER_IMAGE}:latest .
                        
                        # Tag with build number for versioning
                        docker tag ${DOCKER_IMAGE}:latest ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    '''
                }
            }
        }
        
        stage('Deploy to Local Environment') {
            steps {
                echo 'Deploying application locally...'
                sh '''
                    echo "Stopping any existing container..."
                    docker stop ${APP_NAME} || true
                    docker rm ${APP_NAME} || true
                    
                    echo "Starting new container..."
                    docker run -d --name ${APP_NAME} -p 9090:9090 ${DOCKER_IMAGE}:latest
                    
                    echo "Waiting for application to start..."
                    sleep 10
                    
                    echo "Testing application endpoint..."
                    curl -f http://localhost:9090 || exit 1
                    
                    echo "Application deployed successfully!"
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed!'
        }
        success {
            echo 'Pipeline executed successfully!'
            echo 'Application is running at http://localhost:9090'
        }
        failure {
            echo 'Pipeline execution failed!'
            sh 'docker logs ${APP_NAME} || echo "No container logs available"'
        }
    }
}
