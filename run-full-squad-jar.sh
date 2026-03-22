#!/bin/bash
set -euo pipefail

# Check if Docker daemon is running
docker info >/dev/null 2>&1 || { echo "Error: Docker daemon is not running."; echo "Please start Docker and run this script again."; exit 1; }

# Remove existing build folders to prepare for fresh checkout
rm -rf ./build/spring-base
rm -rf ./build/spring-base-event

# Clone repositories with shallow depth to save bandwidth
git clone --depth 1 https://github.com/vulinh64/spring-base.git ./build/spring-base
git clone --depth 1 https://github.com/vulinh64/spring-base-event.git ./build/spring-base-event

COMMONS_NAME=spring-base-commons
COMMONS_GROUP_ID=com.vulinh
COMMONS_VERSION=2.5.0
GITHUB_USER=vulinh64

JAR_FILE="${COMMONS_NAME}-${COMMONS_VERSION}.jar"
DOWNLOAD_URL="https://github.com/${GITHUB_USER}/${COMMONS_NAME}/releases/download/${COMMONS_VERSION}/${JAR_FILE}"

# Create build directory if it doesn't exist
mkdir -p ./build

# Download the JAR file
echo "Downloading ${JAR_FILE}..."
curl -L -o "./build/${JAR_FILE}" "${DOWNLOAD_URL}"

if [ $? -ne 0 ]; then
    echo "Failed to download JAR file"
    exit 1
fi

# Clean the target folder in local .m2 repository if it exists
M2_PATH="${HOME}/.m2/repository/${COMMONS_GROUP_ID//./\/}/${COMMONS_NAME}/${COMMONS_VERSION}"

if [ -d "${M2_PATH}" ]; then
    echo "Cleaning existing Maven repository folder..."
    rm -rf "${M2_PATH}"
fi

# Install the JAR to local Maven repository
echo "Installing ${JAR_FILE} to local Maven repository..."
./mvnw install:install-file \
    -Dfile="./build/${JAR_FILE}" \
    -DgroupId="${COMMONS_GROUP_ID}" \
    -DartifactId="${COMMONS_NAME}" \
    -Dversion="${COMMONS_VERSION}" \
    -Dpackaging=jar

if [ $? -ne 0 ]; then
    echo "Failed to install JAR file"
    exit 1
fi

echo "Successfully installed ${COMMONS_NAME} version ${COMMONS_VERSION}"

# Remove .git directories to clean up version control metadata
rm -rf ./build/spring-base/.git
rm -rf ./build/spring-base-event/.git

# Build both Spring Boot applications using Maven on host OS (skipping tests)
./mvnw clean install -DskipTests -f ./build/spring-base/pom.xml
./mvnw clean install -DskipTests -f ./build/spring-base-event/pom.xml

# Stop existing containers, remove old images, and start fresh containers
docker compose down || true

docker compose -f ./build/spring-base/docker-compose.yml down || true
docker compose -f ./build/spring-base-event/docker-compose.yml down || true

docker rmi --force spring-base:1.0.0 || true
docker rmi --force spring-base-event:1.0.0 || true
docker compose -f docker-compose-local-jar.yml up --detach

# Initialize Keycloak data (realm, client, roles, and users)
chmod +x ./build/spring-base/create-keycloak-data.sh
./build/spring-base/create-keycloak-data.sh