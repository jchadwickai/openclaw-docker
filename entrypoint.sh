#!/bin/bash
set -e

# Authenticate gh CLI with GitHub token if available
if [ -n "$GITHUB_TOKEN" ]; then
    echo "Authenticating gh CLI with GitHub token..."
    echo "$GITHUB_TOKEN" | gh auth login --with-token

    # Setup git to use gh as credential helper
    echo "Setting up git credentials with gh..."
    gh auth setup-git
fi

# Execute the original command
exec "$@"
