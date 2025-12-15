#!/bin/bash
set -euo pipefail

# Check if Docker daemon is running
docker info >/dev/null 2>&1 || { echo "Error: Docker daemon is not running."; echo "Please start Docker and run this script again."; exit 1; }

# Remove existing build folders to prepare for fresh checkout
rm -rf ./build/spring-base ./build/spring-base-event ./build/spring-base-commons

# Clone repositories with shallow depth to save bandwidth
git clone --depth 1 https://github.com/vulinh64/spring-base.git ./build/spring-base
git clone --depth 1 https://github.com/vulinh64/spring-base-event.git ./build/spring-base-event
git clone --depth 1 https://github.com/vulinh64/spring-base-commons.git ./build/spring-base-commons

# Remove .git directories to clean up version control metadata
rm -rf ./build/spring-base/.git
rm -rf ./build/spring-base-event/.git
rm -rf ./build/spring-base-commons/.git

# Build the spring-base-commons artifact using Maven
./build/spring-base-commons/mvnw clean install -f ./build/spring-base-commons/pom.xml

# Create directories
mkdir -p ./build/spring-base/build/spring-base-commons/target
mkdir -p ./build/spring-base-event/build/spring-base-commons/target

# Set version variable for spring-base-commons
SPRING_BASE_COMMONS_VERSION=1.0.0

# Copy the built JAR file to both project build directories for Docker builds
cp ./build/spring-base-commons/target/spring-base-commons-${SPRING_BASE_COMMONS_VERSION}.jar ./build/spring-base/build/spring-base-commons/target/spring-base-commons-${SPRING_BASE_COMMONS_VERSION}.jar
cp ./build/spring-base-commons/target/spring-base-commons-${SPRING_BASE_COMMONS_VERSION}.jar ./build/spring-base-event/build/spring-base-commons/target/spring-base-commons-${SPRING_BASE_COMMONS_VERSION}.jar

# Stop existing containers, remove old images, and start fresh containers
docker compose down || true
docker rmi --force spring-base:1.0.0 || true
docker rmi --force spring-base-event:1.0.0 || true
docker compose up --detach

chmod +x ./build/spring-base/create-keycloak-data.sh

./build/spring-base/create-keycloak-data.sh