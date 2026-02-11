#!/bin/sh
set -e

CONFIG_DIR="/var/syncthing/config"
CONFIG_FILE="$CONFIG_DIR/config.xml"
TEMPLATE_FILE="/config-template/config.xml"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# If config doesn't exist, copy template
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Initializing Syncthing config from template..."
    cp "$TEMPLATE_FILE" "$CONFIG_FILE"
    echo "Config initialized. Syncthing will generate device ID on first start."
fi

# Call the official entrypoint
exec /bin/entrypoint.sh /bin/syncthing "$@"
