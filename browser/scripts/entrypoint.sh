#!/bin/bash
set -e

echo "Starting OpenClaw Browser Service..."

# Start Chrome on port 19222 (internal) in the background
echo "Starting Chrome with remote debugging on port 19222..."
/usr/local/bin/chrome \
  --headless=new \
  --remote-debugging-port=19222 \
  --remote-allow-origins='*' \
  --no-sandbox \
  --disable-gpu \
  --disable-dev-shm-usage \
  --disable-software-rasterizer \
  --disable-setuid-sandbox \
  --log-level=3 \
  --disable-breakpad \
  --disable-sync \
  --disable-features=TranslateUI \
  --disable-background-networking \
  --disable-default-apps \
  --metrics-recording-only \
  --mute-audio \
  "$@" 2>/dev/null &

CHROME_PID=$!
echo "Chrome started (PID: $CHROME_PID)"

# Wait for Chrome to start
sleep 2

# Start nginx reverse proxy (rewrites Host header to localhost)
echo "Starting nginx reverse proxy on port 9222..."
nginx -g 'daemon off;' &

NGINX_PID=$!
echo "Nginx started (PID: $NGINX_PID)"

# Create a default blank page so tabs are visible in DevTools
echo "Creating default page..."
sleep 1
curl -s -X PUT 'http://localhost:19222/json/new?about:blank' > /dev/null || true
echo "Browser service ready - Chrome remote debugging available at port 9222"

# Wait for either process to exit
wait -n $CHROME_PID $NGINX_PID
