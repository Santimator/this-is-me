#!/bin/bash
# This script is to be run with together with
# opencode-hugo.dockerfile

# --- Configuration ---
IMAGE_NAME="opencode-sandbox"
CONTAINER_NAME="opencode_sandbox"
AUTH_PATH="$HOME/.local/share/opencode/auth.json"
PROJECT_PATH="/home/devuser/project"
AUTH_CONTAINER_PATH="/home/devuser/.local/share/opencode/auth.json"

# --- 1. Preparation: Pull latest changes from the host ---
echo "--- 1. Pulling latest changes from repository ---"
git pull || { echo "ERROR: git pull failed. Fix conflicts before running."; exit 1; }

# --- 2. Setup MCP Memory and OpenCode configuration ---
echo "--- 2. Checking OpenCode and MCP configuration ---"

# Check and create MCP memory config if missing
if [ ! -f "mcp-memory/config.yaml" ]; then
    echo "Creating default MCP memory config..."
    mkdir -p mcp-memory
    cat > mcp-memory/config.yaml << 'EOF'
# Local Memory MCP Server Configuration
# Edit this file to customize behavior
EOF
fi

# Check and create opencode.jsonc if missing
if [ ! -f "opencode.jsonc" ]; then
    echo "Creating default opencode.jsonc configuration..."
    cat > opencode.jsonc << 'EOF'
{
  "$schema": "https://opencode.ai/schemas/config.json",
  "mcp": {
    "local-memory": {
      "type": "local",
      "enabled": true,
      "command": [
        "npx",
        "local-memory",
        "--mcp",
        "--config",
        "/home/devuser/project/mcp-memory/config.yaml"
      ],
      "environment": {
        "LOCAL_MEMORY_DIR": "/home/devuser/project/mcp-memory"
      }
    }
  }
}
EOF
    echo "NOTE: Default opencode.jsonc created. You can customize it for this project."
fi

# --- 3. Run the Docker Container and Execute OpenCode ---
echo "--- 3. Starting isolated container and running OpenCode ---"

# Check if auth file exists and mount it if available
if [ ! -f "$AUTH_PATH" ]; then
    echo "NOTE: No OpenCode Zen auth found. Using free models only."
    echo "Run 'opencode auth login' on the host to access additional models."
    docker run -it --rm \
        -v "$(pwd)":$PROJECT_PATH \
        --name "$CONTAINER_NAME" \
        "$IMAGE_NAME" \
        /home/devuser/.opencode/bin/opencode
else
    echo "--- OpenCode Zen authentication found. Full model access enabled. ---"
    docker run -it --rm \
        -v "$(pwd)":$PROJECT_PATH \
        -v "$AUTH_PATH":$AUTH_CONTAINER_PATH:ro \
        --name "$CONTAINER_NAME" \
        "$IMAGE_NAME" \
        /home/devuser/.opencode/bin/opencode
fi

# --- 4. Wrap-up ---
echo "--- 4. AI Session Complete. Container destroyed. ---"
echo "Review the changes locally and run 'git commit' on the host to save."

exit 0
