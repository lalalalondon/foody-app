# Multi-stage build for full-stack application
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY foody-frontend/package*.json ./
RUN npm ci
COPY foody-frontend/ ./
RUN npm run build

FROM eclipse-temurin:21
WORKDIR /app

# Install nginx for serving Angular
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Copy backend JAR
ARG JAR_FILE=foody-backend/target/*.jar
COPY ${JAR_FILE} backend.jar

# Copy frontend build to nginx
COPY --from=frontend-builder /app/frontend/dist/foody-frontend /usr/share/nginx/html

# Copy SQLite database
RUN mkdir -p /app/data
COPY foody-backend/src/main/resources/database/foodyapp.db /app/data/

# Configure nginx to proxy API requests to backend
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://localhost:9090/; \
    } \
}' > /etc/nginx/sites-available/default

# Start script
RUN echo '#!/bin/sh\n\
service nginx start\n\
java -jar /app/backend.jar' > /app/start.sh && chmod +x /app/start.sh

EXPOSE 80 9090
ENTRYPOINT ["/app/start.sh"]
