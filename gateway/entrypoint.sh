#!/bin/bash
set -e

echo "Starting entrypoint script for OpenClaw Gateway"

gh auth setup-git

echo "Configured git authentication for GitHub CLI"

echo "Starting OpenClaw Gateway..."

exec /usr/local/bin/docker-entrypoint.sh node openclaw.mjs gateway --allow-unconfigured
