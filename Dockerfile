# Use OpenJDK 21 as base image for Spring Boot application
FROM eclipse-temurin:21

LABEL maintainer="admin@foody.com"
LABEL description="Food Delivery Spring Boot Microservice with SQLite"
LABEL version="1.0"

# Create application directory
WORKDIR /app

# Create data directory for SQLite database
RUN mkdir -p /app/data

# Define build argument for JAR file location
ARG JAR_FILE=foody-backend/target/*.jar

# Copy the JAR file from the host's target directory to the container
COPY ${JAR_FILE} app.jar

# Create a non-root user for security (optional but recommended)
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Document which port the application will use
EXPOSE 9090

# Define the default command to execute when the container starts
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
