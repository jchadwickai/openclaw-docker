FROM node:22-bookworm-slim

# Install gh CLI, Bitwarden CLI, uv, Go, and gogcli
USER root
RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    # Install Bitwarden CLI
    curl -L -o bw.zip "https://vault.bitwarden.com/download/?app=cli&platform=linux" && \
    unzip bw.zip && \
    chmod +x bw && \
    mv bw /usr/local/bin/bw && \
    rm bw.zip && \
    # Install uv
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv && \
    mv /root/.local/bin/uvx /usr/local/bin/uvx && \
    # Install Go
    GO_VERSION=1.24.0 && \
    ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt && \
    # Install gogcli
    GOGCLI_VERSION=0.11.0 && \
    curl -fsSL "https://github.com/steipete/gogcli/releases/download/v${GOGCLI_VERSION}/gogcli_${GOGCLI_VERSION}_linux_${ARCH}.tar.gz" -o gogcli.tar.gz && \
    tar -xzf gogcli.tar.gz gog && \
    mv gog /usr/local/bin/gog && \
    rm gogcli.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy and setup entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch back to the original user and configure npm global install location
USER node

# Use our entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
