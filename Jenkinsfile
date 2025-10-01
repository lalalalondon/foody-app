pipeline {
    agent any
    
    tools {
        nodejs 'NodeJS'
        maven 'Maven' // You'll need to configure Maven in Jenkins Global Tools
    }
    
    environment {
        FRONTEND_IMAGE = 'foody-frontend'
        BACKEND_IMAGE = 'foody-backend'
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

        stage('Build Frontend') {
            steps {
                dir("${FRONTEND_DIR}") {
                    echo 'Building Angular frontend...'
                    sh '''
                        echo "=== Installing dependencies ==="
                        npm install
                        
                        echo "=== Building Angular app ==="
                        npm run build || npx ng build
                        
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
        }

        stage('Build Backend') {
            steps {
                dir("${BACKEND_DIR}") {
                    echo 'Building Spring Boot backend...'
                    sh '''
                        echo "=== Building Java application with Maven ==="
                        
                        # Check if mvnw exists (Maven wrapper)
                        if [ -f "mvnw" ]; then
                            echo "Using Maven Wrapper"
                            chmod +x mvnw
                            ./mvnw clean package -DskipTests
                        elif [ -f "pom.xml" ]; then
                            echo "Using system Maven"
                            mvn clean package -DskipTests
                        else
                            echo "❌ No pom.xml found - not a Maven project"
                            exit 1
                        fi
                        
                        # Verify JAR was created
                        if [ -d "target" ]; then
                            echo "✅ Java build successful"
                            ls -la target/*.jar
                        else
                            echo "❌ Build failed - target folder not found"
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Frontend Docker Image') {
                    steps {
                        echo 'Building frontend Docker image...'
                        sh '''
                            # Create Dockerfile for frontend if it doesn't exist
                            cat > Dockerfile.frontend << 'EOF'
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY foody-frontend/package*.json ./
RUN npm ci || npm install
COPY foody-frontend/ ./
RUN npm run build || npx ng build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist/foody-frontend /usr/share/nginx/html
# If your dist structure is different, adjust the path above
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
                            
                            # Build frontend image
                            docker build -f Dockerfile.frontend -t ${FRONTEND_IMAGE}:latest .
                            echo "✅ Frontend Docker image built"
                        '''
                    }
                }
                
                stage('Backend Docker Image') {
                    steps {
                        echo 'Building backend Docker image...'
                        sh '''
                            # The Dockerfile in root is for Java backend
                            # Build backend image
                            docker build -f Dockerfile -t ${BACKEND_IMAGE}:latest .
                            echo "✅ Backend Docker image built"
                        '''
                    }
                }
            }
        }

        stage('Deploy Containers') {
            parallel {
                stage('Deploy Frontend') {
                    steps {
                        echo 'Deploying frontend container...'
                        sh '''
                            # Stop and remove existing frontend container
                            docker stop foody-frontend || true
                            docker rm foody-frontend || true

                            # Run frontend container on port 3000
                            docker run -d --name foody-frontend \
                                -p 3000:80 \
                                ${FRONTEND_IMAGE}:latest

                            # Verify deployment
                            sleep 3
                            if docker ps | grep foody-frontend; then
                                echo "✅ Frontend deployed on port 3000"
                            else
                                echo "❌ Frontend deployment failed"
                                docker logs foody-frontend
                                exit 1
                            fi
                        '''
                    }
                }
                
                stage('Deploy Backend') {
                    steps {
                        echo 'Deploying backend container...'
                        sh '''
                            # Stop and remove existing backend container
                            docker stop foody-backend || true
                            docker rm foody-backend || true

                            # Create volume for SQLite database persistence
                            docker volume create foody-db-volume || true

                            # Run backend container on port 9090 with volume for SQLite
                            docker run -d --name foody-backend \
                                -p 9090:9090 \
                                -v foody-db-volume:/app/data \
                                ${BACKEND_IMAGE}:latest

                            # Wait for Spring Boot to start (takes longer than Angular)
                            echo "Waiting for Spring Boot to start..."
                            sleep 15

                            # Verify deployment
                            if docker ps | grep foody-backend; then
                                echo "✅ Backend deployed on port 9090"
                                echo "📁 SQLite database persisted in Docker volume"
                            else
                                echo "❌ Backend deployment failed"
                                docker logs foody-backend
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }

        stage('Verify Full Stack') {
            steps {
                echo 'Verifying full stack deployment...'
                sh '''
                    echo "=== Running Containers ==="
                    docker ps
                    
                    echo "=== Testing Frontend ==="
                    curl -I http://localhost:3000 || echo "Frontend might still be starting..."
                    
                    echo "=== Testing Backend ==="
                    curl -I http://localhost:9090 || echo "Backend might still be starting..."
                    
                    echo "=== Network Configuration ==="
                    # Create network for containers to communicate if needed
                    docker network create foody-network || true
                    docker network connect foody-network foody-frontend || true
                    docker network connect foody-network foody-backend || true
                    
                    echo "✅ Full stack deployment complete!"
                    echo "📱 Frontend: http://localhost:3000"
                    echo "🔧 Backend API: http://localhost:9090"
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed!'
        }
        success {
            echo '🎉 Full stack build and deployment successful!'
            sh '''
                echo "=== Access your application ==="
                echo "Frontend (Angular): http://localhost:3000"
                echo "Backend API (Spring Boot): http://localhost:9090"
                
                # If on EC2, show external URLs
                if [ -f /usr/bin/curl ]; then
                    EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")
                    if [ "$EC2_IP" != "localhost" ]; then
                        echo "External Frontend: http://${EC2_IP}:3000"
                        echo "External Backend: http://${EC2_IP}:9090"
                    fi
                fi
            '''
        }
        failure {
            echo '❌ Build or deployment failed'
            sh '''
                echo "=== Checking logs ==="
                docker logs foody-frontend || echo "No frontend logs"
                docker logs foody-backend || echo "No backend logs"
                
                echo "=== Workspace structure ==="
                ls -la
                ls -la ${FRONTEND_DIR}/ || true
                ls -la ${BACKEND_DIR}/ || true
                ls -la ${BACKEND_DIR}/target/ || true
            '''
        }
    }
}
