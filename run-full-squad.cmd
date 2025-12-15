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
IF EXIST .\build\spring-base-commons rmdir /s /q .\build\spring-base-commons

:: Clone repositories with shallow depth to save bandwidth

git clone --depth 1 https://github.com/vulinh64/spring-base.git .\build\spring-base
git clone --depth 1 https://github.com/vulinh64/spring-base-event.git .\build\spring-base-event
git clone --depth 1 https://github.com/vulinh64/spring-base-commons.git .\build\spring-base-commons

:: Remove .git directories to clean up version control metadata

rmdir /s /q .\build\spring-base\.git
rmdir /s /q .\build\spring-base-event\.git
rmdir /s /q .\build\spring-base-commons\.git

:: Build the spring-base-commons artifact using Maven

call .\build\spring-base-commons\mvnw.cmd clean install -f .\build\spring-base-commons\pom.xml

:: Set version variable for spring-base-commons
SET SPRING_BASE_COMMONS_VERSION=1.0.0

:: Copy the built JAR file to both project build directories for Docker builds

echo f | xcopy .\build\spring-base-commons\target\spring-base-commons-!SPRING_BASE_COMMONS_VERSION!.jar .\build\spring-base\build\spring-base-commons\target\spring-base-commons-!SPRING_BASE_COMMONS_VERSION!.jar
echo f | xcopy .\build\spring-base-commons\target\spring-base-commons-!SPRING_BASE_COMMONS_VERSION!.jar .\build\spring-base-event\build\spring-base-commons\target\spring-base-commons-!SPRING_BASE_COMMONS_VERSION!.jar

:: Stop existing containers, remove old images, and start fresh containers

docker compose down

docker compose -f .\build\spring-base\docker-compose.yml down
docker compose -f .\build\spring-base-event\docker-compose.yml down

docker rmi --force spring-base:1.0.0
docker rmi --force spring-base-event:1.0.0
docker compose up --detach

:: Initialize Keycloak data (realm, client, roles, and users)

call .\build\spring-base\create-keycloak-data.cmd

ENDLOCAL