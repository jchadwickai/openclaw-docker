#!/bin/bash
set -euo pipefail

echo "Starting entrypoint script for OpenClaw Gateway"
export NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-/home/node/.npm-global}"
export PATH="${NPM_CONFIG_PREFIX}/bin:${PATH}"

GH_PID=""
BW_PID=""
GATEWAY_PID=""

cleanup() {
    echo "Shutting down processes..."
    for pid in "$GH_PID" "$BW_PID" "$GATEWAY_PID"; do
        if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
        fi
    done
    wait || true
}

trap cleanup SIGINT SIGTERM

start_gh() {
    if gh auth status >/dev/null 2>&1; then
        gh auth setup-git
        echo "Configured git authentication for GitHub CLI"
    else
        echo "No GitHub CLI auth detected; skipping gh auth setup-git"
    fi
}

start_bitwarden() {
    if [ -z "${BW_CLIENTID:-}" ] || [ -z "${BW_CLIENTSECRET:-}" ]; then
        echo "Bitwarden credentials not provided; skipping Bitwarden setup"
        return 0
    fi

    echo "Configuring Bitwarden CLI..."

    if [ -n "${BW_SERVER:-}" ]; then
        bw config server "$BW_SERVER"
    fi

    if ! bw login --check >/dev/null 2>&1; then
        echo "Logging in to Bitwarden with API key..."
        printf "%s\n%s\n" "$BW_CLIENTID" "$BW_CLIENTSECRET" | bw login --apikey >/dev/null
    else
        echo "Already logged in to Bitwarden"
    fi

    if [ -n "${BW_PASSWORD:-}" ]; then
        echo "Unlocking Bitwarden vault..."
        printf "%s" "$BW_PASSWORD" >/tmp/bw_password
        chmod 600 /tmp/bw_password

        BW_SESSION_VALUE="$(bw unlock --passwordfile /tmp/bw_password --raw || true)"
        rm -f /tmp/bw_password

        if [ -n "$BW_SESSION_VALUE" ]; then
            echo "export BW_SESSION='$BW_SESSION_VALUE'" >>/home/node/.bashrc
            echo "Bitwarden vault unlocked successfully"
        else
            echo "Error: Failed to unlock vault"
        fi
    else
        echo "Warning: BW_PASSWORD not set. Vault will need to be unlocked manually."
    fi
}

start_gateway() {
    echo "Starting OpenClaw Gateway..."
    local openclaw_bin="${OPENCLAW_BIN:-${NPM_CONFIG_PREFIX}/bin/openclaw}"
    if [ ! -x "$openclaw_bin" ]; then
        openclaw_bin="$(command -v openclaw || true)"
    fi

    if [ -z "${openclaw_bin:-}" ] || [ ! -x "$openclaw_bin" ]; then
        echo "Error: openclaw binary not found. Checked ${NPM_CONFIG_PREFIX}/bin/openclaw and PATH."
        return 127
    fi

    "$openclaw_bin" gateway --allow-unconfigured
}

start_gh &
GH_PID=$!

start_bitwarden &
BW_PID=$!

start_gateway &
GATEWAY_PID=$!

wait "$GATEWAY_PID"
