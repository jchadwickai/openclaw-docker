#!/bin/bash
set -e

echo "Starting entrypoint script for OpenClaw Gateway"

gh auth setup-git

echo "Configured git authentication for GitHub CLI"

# Configure Bitwarden CLI if credentials are provided
if [ -n "$BW_CLIENTID" ] && [ -n "$BW_CLIENTSECRET" ]; then
    echo "Configuring Bitwarden CLI..."

    # Set server if custom server is provided
    if [ -n "$BW_SERVER" ]; then
        bw config server "$BW_SERVER"
    fi

    # Check if already logged in
    if ! bw login --check > /dev/null 2>&1; then
        # Login with API key via stdin
        echo "Logging in to Bitwarden with API key..."
        echo -e "$BW_CLIENTID\n$BW_CLIENTSECRET" | bw login --apikey > /dev/null
    else
        echo "Already logged in to Bitwarden"
    fi

    # Unlock vault and export session key
    if [ -n "$BW_PASSWORD" ]; then
        echo "Unlocking Bitwarden vault..."

        # Create temporary password file
        printf "%s" "$BW_PASSWORD" > /tmp/bw_password
        chmod 600 /tmp/bw_password

        # Unlock and capture session key
        BW_SESSION_VALUE=$(bw unlock --passwordfile /tmp/bw_password --raw)

        # Clean up password file
        rm -f /tmp/bw_password

        if [ -n "$BW_SESSION_VALUE" ]; then
            export BW_SESSION="$BW_SESSION_VALUE"
            # Also write to profile so it's available in interactive shells
            echo "export BW_SESSION='$BW_SESSION_VALUE'" >> /home/node/.bashrc
            echo "Bitwarden vault unlocked successfully"
        else
            echo "Error: Failed to unlock vault"
        fi
    else
        echo "Warning: BW_PASSWORD not set. Vault will need to be unlocked manually."
    fi
fi

echo "Starting OpenClaw Gateway..."

exec /usr/local/bin/docker-entrypoint.sh node openclaw.mjs gateway --allow-unconfigured
