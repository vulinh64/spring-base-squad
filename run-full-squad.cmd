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
IF EXIST .\build\spring-base-auth rmdir /s /q .\build\spring-base-auth

:: Clone repositories with shallow depth to save bandwidth

git clone --depth 1 https://github.com/vulinh64/spring-base.git .\build\spring-base
git clone --depth 1 https://github.com/vulinh64/spring-base-event.git .\build\spring-base-event
git clone --depth 1 https://github.com/vulinh64/spring-base-auth.git .\build\spring-base-auth

:: Remove .git directories to clean up version control metadata

rmdir /s /q .\build\spring-base\.git
rmdir /s /q .\build\spring-base-event\.git
rmdir /s /q .\build\spring-base-auth\.git

:: Stop existing containers, remove old images, and start fresh containers

docker compose down
docker compose -f docker-compose-full-stack.yml down

docker rmi --force spring-base:3.0.0-alpha
docker rmi --force spring-base-event:3.0.0-alpha
docker rmi --force spring-base-auth:3.0.0-alpha

docker compose build
docker compose up --detach

ENDLOCAL
