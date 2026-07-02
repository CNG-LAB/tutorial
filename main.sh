#!bin/bash

set -euo pipefail

ensure_uv_installed() {
    echo "Checking system dependencies..."
    if ! command -v uv; then
        echo "'uv' is not installed. Installing it now..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
        echo "'uv' installed successfully."
    else
        echo "'uv' is already installed."
    fi
    echo "-------------------------------------------"
}

# ========================================================
# MAIN EXECUTION FLOW
# ========================================================
echo "Starting Tutorial Setup"
echo "-------------------------------"

# Pre-flight
ensure_uv_installed

echo "Running the Tutorial notebook"
uv run jupyter lab