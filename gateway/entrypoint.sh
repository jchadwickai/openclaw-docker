#!/bin/bash
set -e

echo "Starting entrypoint script for OpenClaw Gateway"

gh auth setup-git

echo "Configured git authentication for GitHub CLI"

# Configure Bitwarden CLI if credentials are provided
if [ -n "$BW_CLIENTID" ] && [ -n "$BW_CLIENTSECRET" ]; then
    echo "Configuring Bitwarden CLI..."

    # Login with API key
    bw login --apikey --raw

    # Unlock vault and export session key
    if [ -n "$BW_PASSWORD" ]; then
        export BW_SESSION=$(bw unlock "$BW_PASSWORD" --raw)
        echo "Bitwarden vault unlocked successfully"
    else
        echo "Warning: BW_PASSWORD not set. Vault will need to be unlocked manually."
    fi
fi

echo "Starting OpenClaw Gateway..."

exec /usr/local/bin/docker-entrypoint.sh node openclaw.mjs gateway --allow-unconfigured
