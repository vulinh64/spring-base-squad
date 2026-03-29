#!/bin/bash

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker daemon is not running."
    echo "Please start Docker Desktop or Docker service and run this script again."
    exit 1
fi

# Remove existing build folders to prepare for fresh checkout

rm -rf ./build/spring-base
rm -rf ./build/spring-base-event
rm -rf ./build/spring-base-frontend

# Clone repositories with shallow depth to save bandwidth

# TODO: just clone from the main branch when done with the testing
git clone --depth 1 --branch test-integrate-frontend https://github.com/vulinh64/spring-base.git ./build/spring-base
git clone --depth 1 https://github.com/vulinh64/spring-base-event.git ./build/spring-base-event
git clone --depth 1 https://github.com/vulinh64/spring-base-frontend.git ./build/spring-base-frontend

# Remove .git directories to clean up version control metadata

rm -rf ./build/spring-base/.git
rm -rf ./build/spring-base-event/.git
rm -rf ./build/spring-base-frontend/.git

# Stop existing containers, remove old images, and start fresh containers

docker compose down

docker compose -f ./build/spring-base/docker-compose.yml down
docker compose -f ./build/spring-base-event/docker-compose.yml down
docker compose -f ./docker-compose-full-stack.yml down

docker rmi --force spring-base:1.0.0
docker rmi --force spring-base-event:1.0.0
docker rmi --force spring-base-frontend:1.0.0

# I need this or the compose up won't detach (?)
docker compose -f docker-compose-full-stack.yml build
docker compose -f docker-compose-full-stack.yml up --detach

# Initialize Keycloak data (realm, client, roles, and users)

./build/spring-base/create-keycloak-data.sh
