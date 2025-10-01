# Stage 1: Build Angular Frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /app
COPY foody-frontend/package*.json ./
RUN npm ci || npm install
COPY foody-frontend/ ./
RUN npm run build || npx ng build

# Stage 2: Setup Java Backend with Frontend
FROM eclipse-temurin:21
WORKDIR /app

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Copy backend JAR
COPY foody-backend/target/*.jar backend.jar

# Copy frontend build (check if it's in browser subfolder for Angular 17+)
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

# Copy SQLite database
RUN mkdir -p /app/data
COPY foody-backend/src/main/resources/database/foodyapp.db /app/data/

# Configure nginx
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://localhost:9090/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
}' > /etc/nginx/sites-available/default

# Create start script
RUN echo '#!/bin/bash\n\
service nginx start\n\
java -jar /app/backend.jar' > /app/start.sh && \
chmod +x /app/start.sh

EXPOSE 80 9090
ENTRYPOINT ["/app/start.sh"]

# Copy SQLite database
RUN mkdir -p /app/data
COPY foody-backend/src/main/resources/database/foodyapp.db /app/data/

# Configure nginx
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://localhost:9090/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
}' > /etc/nginx/sites-available/default

# Create start script
RUN echo '#!/bin/bash\n\
service nginx start\n\
java -jar /app/backend.jar' > /app/start.sh && \
chmod +x /app/start.sh

EXPOSE 80 9090
ENTRYPOINT ["/app/start.sh"]
