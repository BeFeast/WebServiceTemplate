#!/bin/bash
set -e

# Sets up NPM proxy hosts for frontend and backend API
# This script runs locally on DevBox (10.10.0.13)

PROJECT_NAME="${1:?Project name required}"
FRONTEND_PORT="${2:-3000}"
BACKEND_PORT="${3:-8000}"

NPM_URL="http://10.10.0.20:81"
NPM_USER="oleg@befeast.com"
NPM_PASS="HIGb*Knef95zr52Is&"
TARGET_IP="10.10.0.13"
WILDCARD_CERT_ID=15  # *.oklabs.uk certificate

echo "Setting up NPM proxy hosts for ${PROJECT_NAME}..."

# Get NPM token
echo "Authenticating with NPM..."
NPM_TOKEN=$(curl -s -X POST "${NPM_URL}/api/tokens" \
    -H "Content-Type: application/json" \
    -d "{\"identity\":\"${NPM_USER}\",\"secret\":\"${NPM_PASS}\"}" | jq -r '.token')

if [[ -z "$NPM_TOKEN" || "$NPM_TOKEN" == "null" ]]; then
    echo "Error: Failed to authenticate with NPM"
    exit 1
fi

echo "✅ Authenticated with NPM"

# Create frontend proxy host
echo "Creating frontend proxy: ${PROJECT_NAME}.oklabs.uk -> ${TARGET_IP}:${FRONTEND_PORT}"
FRONTEND_RESULT=$(curl -s -X POST "${NPM_URL}/api/nginx/proxy-hosts" \
    -H "Authorization: Bearer ${NPM_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
        \"domain_names\": [\"${PROJECT_NAME}.oklabs.uk\"],
        \"forward_scheme\": \"http\",
        \"forward_host\": \"${TARGET_IP}\",
        \"forward_port\": ${FRONTEND_PORT},
        \"certificate_id\": ${WILDCARD_CERT_ID},
        \"ssl_forced\": true,
        \"http2_support\": true,
        \"block_exploits\": true,
        \"allow_websocket_upgrade\": true,
        \"access_list_id\": 0,
        \"advanced_config\": \"\",
        \"enabled\": 1,
        \"meta\": {
            \"letsencrypt_agree\": false,
            \"dns_challenge\": false
        },
        \"locations\": []
    }")

if echo "$FRONTEND_RESULT" | jq -e '.id' > /dev/null 2>&1; then
    echo "✅ Frontend proxy created: https://${PROJECT_NAME}.oklabs.uk"
else
    echo "⚠️  Frontend proxy may already exist or failed: $FRONTEND_RESULT"
fi

# Create backend API proxy host
echo "Creating backend proxy: ${PROJECT_NAME}-api.oklabs.uk -> ${TARGET_IP}:${BACKEND_PORT}"
BACKEND_RESULT=$(curl -s -X POST "${NPM_URL}/api/nginx/proxy-hosts" \
    -H "Authorization: Bearer ${NPM_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
        \"domain_names\": [\"${PROJECT_NAME}-api.oklabs.uk\"],
        \"forward_scheme\": \"http\",
        \"forward_host\": \"${TARGET_IP}\",
        \"forward_port\": ${BACKEND_PORT},
        \"certificate_id\": ${WILDCARD_CERT_ID},
        \"ssl_forced\": true,
        \"http2_support\": true,
        \"block_exploits\": true,
        \"allow_websocket_upgrade\": true,
        \"access_list_id\": 0,
        \"advanced_config\": \"\",
        \"enabled\": 1,
        \"meta\": {
            \"letsencrypt_agree\": false,
            \"dns_challenge\": false
        },
        \"locations\": []
    }")

if echo "$BACKEND_RESULT" | jq -e '.id' > /dev/null 2>&1; then
    echo "✅ Backend proxy created: https://${PROJECT_NAME}-api.oklabs.uk"
else
    echo "⚠️  Backend proxy may already exist or failed: $BACKEND_RESULT"
fi

echo ""
echo "NPM proxy setup complete!"
echo ""
echo "Access URLs:"
echo "  Frontend: https://${PROJECT_NAME}.oklabs.uk"
echo "  Backend:  https://${PROJECT_NAME}-api.oklabs.uk"
echo "  API Docs: https://${PROJECT_NAME}-api.oklabs.uk/docs"
