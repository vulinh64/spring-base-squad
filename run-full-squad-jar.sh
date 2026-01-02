#!/bin/bash
set -euo pipefail

# Check if Docker daemon is running
docker info >/dev/null 2>&1 || { echo "Error: Docker daemon is not running."; echo "Please start Docker and run this script again."; exit 1; }

# Remove existing build folders to prepare for fresh checkout
rm -rf ./build/spring-base
rm -rf ./build/spring-base-event
rm -rf ./build/spring-base-commons

# Clone repositories with shallow depth to save bandwidth
git clone --depth 1 https://github.com/vulinh64/spring-base.git ./build/spring-base
git clone --depth 1 https://github.com/vulinh64/spring-base-event.git ./build/spring-base-event

SPRING_BASE_COMMONS_VERSION=2.3.0

git clone --depth 1 --branch "${SPRING_BASE_COMMONS_VERSION}" https://github.com/vulinh64/spring-base-commons.git ./build/spring-base-commons

# Remove .git directories to clean up version control metadata
rm -rf ./build/spring-base/.git
rm -rf ./build/spring-base-event/.git
rm -rf ./build/spring-base-commons/.git

# Build the spring-base-commons artifact using Maven
chmod +x ./build/spring-base-commons/mvnw

./build/spring-base-commons/mvnw clean install -f ./build/spring-base-commons/pom.xml


# Build both Spring Boot applications using Maven on host OS (skipping tests)
./build/spring-base/mvnw clean install -DskipTests -f ./build/spring-base/pom.xml
./build/spring-base-event/mvnw clean install -DskipTests -f ./build/spring-base-event/pom.xml

# Stop existing containers, remove old images, and start fresh containers
docker compose down || true

docker compose -f ./build/spring-base/docker-compose.yml down || true
docker compose -f ./build/spring-base-event/docker-compose.yml down || true

docker rmi --force spring-base:1.0.0 || true
docker rmi --force spring-base-event:1.0.0 || true
docker compose -f docker-compose-1.yml up --detach

# Initialize Keycloak data (realm, client, roles, and users)
chmod +x ./build/spring-base/create-keycloak-data.sh
./build/spring-base/create-keycloak-data.sh