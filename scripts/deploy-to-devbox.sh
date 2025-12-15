#!/bin/bash
set -e

# Deploys the stack to DevBox via Portainer API or direct docker-compose
# This script runs locally on DevBox (10.10.0.13)

PROJECT_NAME="${1:-$(grep PROJECT_NAME .env 2>/dev/null | cut -d= -f2)}"
PROJECT_NAME="${PROJECT_NAME:-{{PROJECT_NAME}}}"

DEV_PATH="/opt/projects/${PROJECT_NAME}"
STACK_PATH="/opt/stacks/${PROJECT_NAME}"

PORTAINER_URL="https://devbox.oklabs.uk"
PORTAINER_API_KEY="${PORTAINER_API_KEY:-}"
ENDPOINT_ID=1

echo "Deploying ${PROJECT_NAME}..."
echo "  Development: ${DEV_PATH}"
echo "  Stack: ${STACK_PATH}"

# Create stack directory
mkdir -p "${STACK_PATH}"

# Copy compose files and .env to stack directory
echo "Copying files to stack directory..."
cp docker/docker-compose.yml "${STACK_PATH}/"
cp .env "${STACK_PATH}/"

# Build images
echo "Building images..."
cd "${STACK_PATH}" && docker compose build

# Deploy via Portainer API if key is available
if [[ -n "$PORTAINER_API_KEY" ]]; then
    echo "Deploying via Portainer API..."
    
    # Check if stack exists
    STACK_ID=$(curl -s "${PORTAINER_URL}/api/stacks" \
        -H "X-API-Key: ${PORTAINER_API_KEY}" | \
        jq -r ".[] | select(.Name==\"${PROJECT_NAME}\") | .Id")
    
    if [[ -n "$STACK_ID" && "$STACK_ID" != "null" ]]; then
        echo "Updating existing stack (ID: ${STACK_ID})..."
        curl -X PUT "${PORTAINER_URL}/api/stacks/${STACK_ID}?endpointId=${ENDPOINT_ID}" \
            -H "X-API-Key: ${PORTAINER_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "{\"stackFileContent\": $(cat docker/docker-compose.yml | jq -Rs .), \"env\": [], \"prune\": true}"
    else
        echo "Creating new stack..."
        curl -X POST "${PORTAINER_URL}/api/stacks?type=2&method=string&endpointId=${ENDPOINT_ID}" \
            -H "X-API-Key: ${PORTAINER_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "{\"name\": \"${PROJECT_NAME}\", \"stackFileContent\": $(cat docker/docker-compose.yml | jq -Rs .)}"
    fi
else
    echo "No Portainer API key found. Deploying via docker-compose..."
    cd "${STACK_PATH}" && docker compose up -d
fi

echo ""
echo "Deployment complete!"
echo "Stack is running at: https://${PROJECT_NAME}.oklabs.uk"
