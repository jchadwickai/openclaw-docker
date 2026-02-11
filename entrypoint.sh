#!/bin/bash
set -e

gh auth setup-git

# Execute the original command
exec "$@"
