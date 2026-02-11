# Syncthing Setup for OpenClaw Workspace

This directory contains configuration for syncing the OpenClaw workspace directory (`/home/node/.openclaw/workspace`) across devices using Syncthing.

## Setup

1. Start the services:
   ```bash
   docker-compose up -d
   ```

2. Access the Syncthing Web UI:
   - Open http://localhost:8384
   - The workspace folder is **already configured** as "OpenClaw Workspace" (`/data/workspace`)

3. Add remote devices:
   - In the Syncthing Web UI, click "Add Remote Device"
   - Enter the Device ID of the device you want to sync with
   - Share the "OpenClaw Workspace" folder with that device
   - Accept the connection on the remote device

## What Gets Synced

The entire `/home/node/.openclaw/workspace` directory is synced, **except**:
- `.git/` directories (git metadata)
- `node_modules/` directories
- Lock files (package-lock.json, yarn.lock, etc.)
- OS-specific files (.DS_Store, Thumbs.db)

See `.stignore` for the complete list of exclusions.

## Ports

- **8384**: Web UI (http://localhost:8384)
- **22000**: File transfer (TCP and UDP/QUIC)
- **21027**: Local discovery (UDP)

## Notes

- The `.stignore` file is mounted read-only from this directory
- To modify ignore patterns, edit `syncthing/.stignore` and restart the container
- Syncthing config is persisted in the `syncthing-config` Docker volume
