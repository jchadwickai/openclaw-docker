FROM node:22-bookworm-slim

# Install gh CLI, Bitwarden CLI, uv, Go, and gogcli
USER root

# Copy and setup entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch back to the original user and configure npm global install location
USER node

# Use our entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
