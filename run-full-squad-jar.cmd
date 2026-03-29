@echo off
SETLOCAL EnableDelayedExpansion

REM Check if Docker daemon is running
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

SET COMMONS_NAME=spring-base-commons
SET COMMONS_GROUP_ID=com.vulinh
SET COMMONS_VERSION=2.5.0
SET GITHUB_USER=vulinh64

SET JAR_FILE=%COMMONS_NAME%-%COMMONS_VERSION%.jar
SET DOWNLOAD_URL=https://github.com/%GITHUB_USER%/%COMMONS_NAME%/releases/download/%COMMONS_VERSION%/%JAR_FILE%

:: Create build directory if it doesn't exist
IF NOT EXIST .\build mkdir .\build

:: Download the JAR file
echo Downloading %JAR_FILE%...
curl -L -o .\build\%JAR_FILE% %DOWNLOAD_URL%

IF %ERRORLEVEL% NEQ 0 (
    echo Failed to download JAR file
    exit /b 1
)

:: Clean the target folder in local .m2 repository if it exists
SET M2_PATH=%USERPROFILE%\.m2\repository\%COMMONS_GROUP_ID:.=\%\%COMMONS_NAME%\%COMMONS_VERSION%

IF EXIST "%M2_PATH%" (
    echo Cleaning existing Maven repository folder...
    rmdir /s /q "%M2_PATH%"
)

:: Install the JAR to local Maven repository
echo Installing %JAR_FILE% to local Maven repository...
call .\mvnw.cmd install:install-file ^
    -Dfile=.\build\%JAR_FILE% ^
    -DgroupId=%COMMONS_GROUP_ID% ^
    -DartifactId=%COMMONS_NAME% ^
    -Dversion=%COMMONS_VERSION% ^
    -Dpackaging=jar

IF %ERRORLEVEL% NEQ 0 (
    echo Failed to install JAR file
    exit /b 1
)

echo Successfully installed %COMMONS_NAME% version %COMMONS_VERSION%

:: Remove .git directories to clean up version control metadata

rmdir /s /q .\build\spring-base\.git
rmdir /s /q .\build\spring-base-event\.git

:: Build both Spring Boot applications using Maven on host OS (skipping tests)

call .\mvnw.cmd clean install -DskipTests -f .\build\spring-base\pom.xml
call .\mvnw.cmd clean install -DskipTests -f .\build\spring-base-event\pom.xml

:: Stop existing containers, remove old images, and start fresh containers

docker compose down

docker compose -f .\build\spring-base\docker-compose.yml down
docker compose -f .\build\spring-base-event\docker-compose.yml down

docker rmi --force spring-base:1.0.0
docker rmi --force spring-base-event:1.0.0
docker compose -f docker-compose-local-jar.yml up --detach

:: Initialize Keycloak data (realm, client, roles, and users)

call .\build\spring-base\create-keycloak-data.cmd

ENDLOCAL