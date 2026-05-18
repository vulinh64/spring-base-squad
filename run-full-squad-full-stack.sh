#!/bin/bash
set -euo pipefail

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker daemon is not running."
    echo "Please start Docker Desktop or Docker service and run this script again."
    exit 1
fi

# Remove existing build folders to prepare for fresh checkout

[ -d ./build/spring-base ] && rm -rf ./build/spring-base
[ -d ./build/spring-base-event ] && rm -rf ./build/spring-base-event
[ -d ./build/spring-base-auth ] && rm -rf ./build/spring-base-auth
[ -d ./build/spring-base-frontend ] && rm -rf ./build/spring-base-frontend

# Clone repositories with shallow depth to save bandwidth

git clone --depth 1 https://github.com/vulinh64/spring-base.git ./build/spring-base
git clone --depth 1 https://github.com/vulinh64/spring-base-event.git ./build/spring-base-event
git clone --depth 1 https://github.com/vulinh64/spring-base-auth.git ./build/spring-base-auth
git clone --depth 1 https://github.com/vulinh64/spring-base-frontend.git ./build/spring-base-frontend

# Remove .git directories to clean up version control metadata

rm -rf ./build/spring-base/.git
rm -rf ./build/spring-base-event/.git
rm -rf ./build/spring-base-auth/.git
rm -rf ./build/spring-base-frontend/.git

# Stop existing containers, remove old images, and start fresh containers

docker compose down || true
docker compose -f docker-compose-full-stack.yml down || true

docker rmi --force spring-base:3.0.0-alpha || true
docker rmi --force spring-base-event:3.0.0-alpha || true
docker rmi --force spring-base-auth:3.0.0-alpha || true
docker rmi --force spring-base-frontend:3.0.0-alpha || true

docker compose -f docker-compose-full-stack.yml build
docker compose -f docker-compose-full-stack.yml up --detach
