#!/bin/bash
set -euo pipefail

# Check if Docker daemon is running
docker info >/dev/null 2>&1 || { echo "Error: Docker daemon is not running."; echo "Please start Docker and run this script again."; exit 1; }

# Remove existing build folders to prepare for fresh checkout
rm -rf ./build/spring-base ./build/spring-base-event

# Clone repositories with shallow depth to save bandwidth
# TODO: just clone from the main branch when done with the testing
git clone --depth 1 --branch test-integrate-frontend https://github.com/vulinh64/spring-base.git .\build\spring-base
git clone --depth 1 https://github.com/vulinh64/spring-base-event.git ./build/spring-base-event

# Remove .git directories to clean up version control metadata
rm -rf ./build/spring-base/.git
rm -rf ./build/spring-base-event/.git

# Stop existing containers, remove old images, and start fresh containers
docker compose down || true

docker compose -f ./build/spring-base/docker-compose.yml down || true
docker compose -f ./build/spring-base-event/docker-compose.yml down || true

docker rmi --force spring-base:1.0.0 || true
docker rmi --force spring-base-event:1.0.0 || true
docker compose up --detach

chmod +x ./build/spring-base/create-keycloak-data.sh

./build/spring-base/create-keycloak-data.sh