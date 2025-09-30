# Use OpenJDK 21 as base image for Spring Boot application
# This provides a complete Java runtime environment with JDK 21
FROM eclipse-temurin:21

# Set metadata for the image to document purpose and maintainer
LABEL maintainer="student@example.com"
LABEL description="Food Delivery Spring Boot Microservice"
LABEL version="1.0"

# Create application directory inside the container
# This is where our application files will be stored
WORKDIR /app

# Define build argument for JAR file location
# ARG allows us to pass the JAR file path during docker build
# The wildcard pattern *.jar will match the generated JAR file
ARG JAR_FILE=target/*.jar

# Copy the JAR file from the host's target directory to the container
# ${JAR_FILE} expands to the actual JAR file path
# We rename it to 'app.jar' for consistency and easier management
COPY ${JAR_FILE} app.jar

# Document which port the application will use
# This is for documentation purposes - doesn't actually publish the port
# The application inside runs on port 9090 as configured in application.properties
EXPOSE 9090

# Define the default command to execute when the container starts
# ENTRYPOINT creates an executable container that always runs this command
# java -jar executes the Spring Boot application
# The JAR file contains an embedded Tomcat server
ENTRYPOINT ["java", "-jar", "/app/app.jar"]