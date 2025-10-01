pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS'
        maven 'Maven'
    }
    
    environment {
        DOCKER_IMAGE = 'foody-app'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Getting source code...'
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                dir('foody-backend') {
                    echo 'Building Java backend...'
                    sh '''
                        mvn clean package -DskipTests
                        ls -la target/*.jar
                    '''
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('foody-frontend') {
                    echo 'Building Angular frontend...'
                    sh '''
                        npm install
                        npm run build
                        ls -la dist/
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t ${DOCKER_IMAGE}:latest .'
            }
        }

        stage('Deploy Locally') {
            steps {
                echo 'Deploying application...'
                sh '''
                    # Stop and remove existing container
                    docker stop foody-app || true
                    docker rm foody-app || true
                    
                    # Run new container
                    docker run -d --name foody-app \
                        -p 80:80 \
                        -p 9090:9090 \
                        ${DOCKER_IMAGE}:latest
                    
                    # Wait for services to start
                    sleep 10
                    
                    # Check if running
                    docker ps | grep foody-app
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment successful! Access at your Jenkins URL'
        }
        failure {
            echo 'Deployment failed! Check logs: docker logs foody-app'
        }
    }
}
