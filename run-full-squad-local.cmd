@echo off
setlocal
pushd "%~dp0" || exit /b 1

for %%P in (spring-base spring-base-auth spring-base-event) do (
    if not exist "..\%%P\Dockerfile" (
        echo Error: missing sibling project ..\%%P\Dockerfile
        goto :failed
    )
)

docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker daemon is not running. Start Docker and try again.
    goto :failed
)

docker compose -f docker-compose.yml -f docker-compose-local.yml config --quiet
if errorlevel 1 goto :failed
:: Additional arguments apply to the build, for example --no-cache --pull.
docker compose -f docker-compose.yml -f docker-compose-local.yml build %*
if errorlevel 1 goto :failed
docker compose -f docker-compose.yml -f docker-compose-local.yml up --detach --no-build
if errorlevel 1 goto :failed

popd
exit /b 0

:failed
popd
exit /b 1
