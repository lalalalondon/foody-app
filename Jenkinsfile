pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS'
    }
    
    environment {
        DOCKER_IMAGE = 'foody-app'
        REPO_URL = 'https://github.com/lalalalondon/foody-app.git'
        FRONTEND_DIR = 'foody-frontend'
        BACKEND_DIR = 'foody-backend'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Getting source code...'
                git branch: 'main', url: env.REPO_URL
                sh 'ls -la'
            }
        }

        stage('Install Frontend Dependencies') {
            steps {
                dir("${FRONTEND_DIR}") {
                    echo 'Installing frontend dependencies...'
                    sh '''
                        pwd
                        ls -la
                        node --version
                        npm --version
                        npm install
                        echo "✅ Frontend dependencies installed"
                    '''
                }
            }
        }

        stage('Build Angular Application') {
            steps {
                dir("${FRONTEND_DIR}") {
                    echo 'Building Angular application...'
                    sh '''
                        # Build the Angular app
                        npm run build || npx ng build
                        
                        # Check if dist folder exists
                        if [ -d "dist" ]; then
                            echo "✅ Angular build successful"
                            ls -la dist/
                        else
                            echo "⚠️ dist folder not found, checking other locations"
                            find . -name "dist" -type d
                        fi
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    # Check if Dockerfile exists in root
                    if [ -f "Dockerfile" ]; then
                        echo "Using existing Dockerfile"
                    else
                        echo "Creating Dockerfile..."
                        cat > Dockerfile << 'EOF'
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY ${FRONTEND_DIR}/package*.json ./
RUN npm ci || npm install
COPY ${FRONTEND_DIR}/ ./
RUN npm run build || npx ng build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist/* /usr/share/nginx/html/
# If dist has a subfolder with app name, use this instead:
# COPY --from=builder /app/dist/foody-frontend /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
                    fi
                    
                    # Build Docker image
                    docker build -t ${DOCKER_IMAGE}:latest .
                    docker images | grep ${DOCKER_IMAGE}
                    echo "✅ Docker image built"
                '''
            }
        }

        stage('Deploy Frontend Container') {
            steps {
                echo 'Deploying frontend container...'
                sh '''
                    # Stop and remove existing container
                    docker stop foody-frontend || true
                    docker rm foody-frontend || true

                    # Run frontend container on port 3000
                    docker run -d --name foody-frontend -p 3000:80 ${DOCKER_IMAGE}:latest

                    # Wait for container to start
                    sleep 5

                    # Verify deployment
                    if docker ps | grep foody-frontend; then
                        echo "✅ Frontend container deployed"
                        echo "🌐 Frontend accessible at port 3000"
                    else
                        echo "❌ Frontend deployment failed"
                        docker logs foody-frontend
                        exit 1
                    fi
                '''
            }
        }

        stage('Deploy Backend (Optional)') {
            when {
                expression { 
                    fileExists("${BACKEND_DIR}/package.json") || 
                    fileExists("${BACKEND_DIR}/pom.xml") || 
                    fileExists("${BACKEND_DIR}/requirements.txt")
                }
            }
            steps {
                echo 'Backend deployment can be configured based on technology used'
                sh '''
                    echo "Backend folder contents:"
                    ls -la ${BACKEND_DIR}/ || echo "Backend folder structure to be determined"
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying full deployment...'
                sh '''
                    echo "=== Running Containers ==="
                    docker ps
                    
                    echo "=== Port Status ==="
                    netstat -tulpn | grep -E "3000|8080" || true
                    
                    echo "=== Test Frontend ==="
                    curl -I http://localhost:3000 || echo "Frontend might still be starting..."
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
            sh '''
                echo "Access your application:"
                echo "Frontend: http://localhost:3000"
                if [ -f /usr/bin/curl ]; then
                    EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")
                    echo "External access: http://${EC2_IP}:3000"
                fi
            '''
        }
        failure {
            echo '❌ Build or deployment failed'
            sh '''
                echo "=== Docker Logs ==="
                docker logs foody-frontend || echo "No frontend container logs"
                echo "=== Checking workspace ==="
                ls -la
                ls -la ${FRONTEND_DIR}/ || true
            '''
        }
    }
}
