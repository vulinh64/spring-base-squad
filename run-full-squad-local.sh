#!/bin/bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

for project in spring-base spring-base-auth spring-base-event; do
    if [[ ! -f "../${project}/Dockerfile" ]]; then
        echo "Error: missing sibling project ../${project}/Dockerfile" >&2
        exit 1
    fi
done

if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker daemon is not running. Start Docker and try again." >&2
    exit 1
fi

compose=(docker compose -f docker-compose.yml -f docker-compose-local.yml)
"${compose[@]}" config --quiet
# Additional arguments apply to the build, for example --no-cache --pull.
"${compose[@]}" build "$@"
"${compose[@]}" up --detach --no-build
