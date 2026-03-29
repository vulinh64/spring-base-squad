@echo off
SETLOCAL EnableDelayedExpansion

:: Check if Docker daemon is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker daemon is not running.
    echo Please start Docker Desktop or Docker service and run this script again.
    exit /b 1
)

:: Remove existing build folders to prepare for fresh checkout

IF EXIST .\build\spring-base rmdir /s /q .\build\spring-base
IF EXIST .\build\spring-base-event rmdir /s /q .\build\spring-base-event

:: Clone repositories with shallow depth to save bandwidth

:: TODO: just clone from the main branch when done with the testing
git clone --depth 1 --branch test-integrate-frontend https://github.com/vulinh64/spring-base.git .\build\spring-base
git clone --depth 1 https://github.com/vulinh64/spring-base-event.git .\build\spring-base-event

:: Remove .git directories to clean up version control metadata

rmdir /s /q .\build\spring-base\.git
rmdir /s /q .\build\spring-base-event\.git

:: Stop existing containers, remove old images, and start fresh containers

docker compose down

docker compose -f .\build\spring-base\docker-compose.yml down
docker compose -f .\build\spring-base-event\docker-compose.yml down

docker rmi --force spring-base:1.0.0
docker rmi --force spring-base-event:1.0.0
docker compose build
docker compose up --detach

:: Initialize Keycloak data (realm, client, roles, and users)

call .\build\spring-base\create-keycloak-data.cmd

ENDLOCAL