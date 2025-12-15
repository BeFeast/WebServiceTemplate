#!/bin/bash
set -e

# Sets up subdomain in NPM and Cloudflare tunnel
# This script runs locally on DevBox (10.10.0.13)

SUBDOMAIN="${1:?Subdomain required}"
TARGET_PORT="${2:-3000}"
TARGET_IP="10.10.0.13"  # Docker LXC 111

echo "Setting up subdomain: ${SUBDOMAIN}.oklabs.uk -> ${TARGET_IP}:${TARGET_PORT}"

# Check if add-subdomain.sh exists locally
if [[ -f /opt/scripts/add-subdomain.sh ]]; then
    echo "Using local add-subdomain.sh script..."
    /opt/scripts/add-subdomain.sh "$SUBDOMAIN" "$TARGET_IP" "$TARGET_PORT" http
else
    echo "Manual setup required:"
    echo ""
    echo "1. NPM (Nginx Proxy Manager):"
    echo "   - URL: http://10.10.0.20:81"
    echo "   - Add Proxy Host:"
    echo "     Domain: ${SUBDOMAIN}.oklabs.uk"
    echo "     Scheme: http"
    echo "     Forward IP: ${TARGET_IP}"
    echo "     Forward Port: ${TARGET_PORT}"
    echo "     SSL: Use wildcard cert (ID: 15 for *.oklabs.uk)"
    echo ""
    echo "2. Cloudflare Tunnel (if external access needed):"
    echo "   - Dashboard: https://dash.cloudflare.com"
    echo "   - Add hostname to tunnel: bfd2ca60-6a86-44d7-9d8b-39d85da70832"
    echo "   - Subdomain: ${SUBDOMAIN}"
    echo "   - Service: http://10.10.0.20:80"
fi

echo ""
echo "Subdomain setup complete!"
echo "Access: https://${SUBDOMAIN}.oklabs.uk"
