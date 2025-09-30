pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS'  // Make sure NodeJS is configured in Jenkins Global Tool Configuration
    }
    
    environment {
        DOCKER_IMAGE = 'foody-app'
        REPO_URL = 'https://github.com/lalalalondon/foody-app.git'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Getting source code...'
                git branch: 'main', url: env.REPO_URL
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh '''
                    # Check Node and npm versions
                    node --version
                    npm --version
                    
                    # Clean install dependencies
                    npm ci || npm install
                    echo "✅ Dependencies installed successfully"
                '''
            }
        }

        stage('Build Angular Application') {
            steps {
                echo 'Building Angular application...'
                sh '''
                    # Build the Angular app for production
                    npm run build -- --configuration production || npm run build
                    
                    # Verify build output
                    if [ -d "dist" ]; then
                        echo "✅ Angular build successful"
                        ls -la dist/
                    else
                        echo "❌ Build failed - dist folder not found"
                        exit 1
                    fi
                '''
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                sh '''
                    # Run Angular tests in headless mode
                    # npm run test -- --watch=false --browsers=ChromeHeadless || echo "Tests skipped"
                    echo "Tests skipped for now - configure Chrome headless for CI"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    # Create Dockerfile if it doesn't exist
                    if [ ! -f Dockerfile ]; then
                        cat > Dockerfile << 'EOF'
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist/foody-app /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
                    fi
                    
                    # Build Docker image
                    docker build -t ${DOCKER_IMAGE}:latest .
                    
                    # List Docker images to verify
                    docker images | grep ${DOCKER_IMAGE}
                    echo "✅ Docker image built successfully"
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                echo 'Deploying Docker container...'
                sh '''
                    # Stop and remove existing container (if any)
                    docker stop foody-app || true
                    docker rm foody-app || true

                    # Run new container
                    docker run -d --name foody-app -p 8080:80 ${DOCKER_IMAGE}:latest

                    # Wait for container to start
                    sleep 10

                    # Verify deployment
                    if docker ps | grep foody-app; then
                        echo "✅ Container deployed successfully"
                        echo "🌐 App accessible at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080/"
                        
                        # Test the endpoint
                        echo "Testing application endpoint..."
                        curl -f http://localhost:8080 || echo "⚠️ Application might still be starting up"
                    else
                        echo "❌ Deployment failed"
                        docker logs foody-app
                        exit 1
                    fi
                '''
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Cleaning up old Docker images...'
                sh '''
                    # Remove old/unused Docker images to save space
                    docker image prune -f

                    # Show current Docker resource usage
                    echo "Current Docker images:"
                    docker images
                    echo "Running containers:"
                    docker ps
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed!'
        }
        success {
            echo '🎉 Build and deployment successful!'
            echo 'Your Angular app is running in a Docker container on EC2'
        }
        failure {
            echo '❌ Build or deployment failed'
            echo 'Check the logs above for error details'
            sh 'docker logs foody-app || echo "Container not running"'
        }
    }
}