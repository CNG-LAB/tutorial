#!/usr/bin/env bash

set -euo pipefail
export UV_LINK_MODE=copy
export UV_CACHE_DIR="/tmp/uv-cache-$USER"

ensure_uv_installed() {
    echo "Checking system dependencies..."
    if ! command -v uv &> /dev/null; then
        echo "'uv' is not installed. Installing it now..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
        echo "'uv' installed successfully."
    else
        echo "'uv' is already installed."
    fi
    echo "-------------------------------------------"
}

init_workspace() {
    local target_dir=$1

    if [ "$target_dir" = "." ]; then
        echo "Initializing workspace inside the CURRENT directory..."
    else
        echo "Building workspace directory: ./$target_dir"
        mkdir -p "$target_dir"
        cd "$target_dir"
    fi

    # echo "Initializing Git repository..."
    # git init
    # git branch -m main 2>/dev/null || true
}

init_workspace() {
    local target_dir=$1
    echo "Building workspace directory: ./$target_dir"
    mkdir -p "$target_dir"
    cd "$target_dir"

    echo "Initializing Git repository..."
    git init
    git branch -m main 2>/dev/null || true
}

gen_gitignore() {
    echo "Generating standard .gitignore dynamically..."
    # The 'EOF' is quoted to ensure strings like $py aren't evaluated as bash variables
    cat << 'EOF' > .gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[codz]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py.cover
*.lcov
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django / Flask / Scrapy
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal
instance/
.webassets-cache
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder / Jupyter / IPython
.pybuilder/
target/
.ipynb_checkpoints
profile_default/
ipython_config.py

# Environments and Package Managers
.env
.envrc
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.pdm-python
.pdm-build/
__pypackages__/
.pixi/*
!.pixi/config.toml

# IDEs (VS Code, PyCharm)
.idea/
.vscode/
.spyderproject
.ropeproject
tempCodeRunnerFile.py

# Tools (Mypy, Ruff, Celery, Redis)
.mypy_cache/
.dmypy.json
dmypy.json
.pyre/
.pytype/
cython_debug/
.ruff_cache/
.pypirc
celerybeat-schedule*
celerybeat.pid
*.rdb
*.aof
*.pid

# Application Specific
marimo/_static/
marimo/_lsp/
__marimo__/
.streamlit/
EOF
}

init_root_env() {
    local target_python=$1
    local python_range=$2

    shift 2

    local global_deps=("$@")

    echo "--------------------------------------------"

    if [ -f "pyproject.toml" ]; then
        echo "Root environment already exists. Synchronizing updates..."
        echo "Updating Python constraint to ${python_range}..."
        sed -i.bak -e "s/requires-python = \".*\"/requires-python = \"${python_range}\"/" pyproject.toml && rm -f pyproject.toml.bak
    else
        echo "Initializing root environment (Python ${target_python})..."
        uv init --no-workspace --python "${target_python}" .
        echo "Enforcing strict Python version constraints: ${python_range}"
        sed -i.bak -e "s/requires-python = \".*\"/requires-python = \"${python_range}\"/" pyproject.toml && rm -f pyproject.toml.bak
    fi

    if [ ${#global_deps[@]} -gt 0 ]; then
        echo "Syncing global dependencies..."
        uv add "${global_deps[@]}"
    fi
}

# =======================================================
# CONFIGURATION VARIABLES
# =======================================================

TARGET_DIR=${1:-"."}
ROOT_PYTHON="3.11"
ROOT_PYTHON_RANGE=">=3.11,<3.12"
ROOT_DEPS=(
    "brainspace>=0.1.10"
    "brainstat>=0.6.0"
    "jupyterlab==4.0.13"
    "nibabel==4.0.0"
    "nilearn>=0.10.4"
    "matplotlib>=3.5.0"
    "numpy==1.23.5"
    "pandas>=1.5.1"
    "pyvirtualdisplay==3.0"
    "scikit-learn>=1.7.2"
    "scipy>=1.13.1"
    "seaborn>=0.13.2"
    "session-info==1.0.1"
    "setuptools>=82.0.1"
    "vtk==9.2.6"
)

# ========================================================
# MAIN EXECUTION FLOW
# ========================================================
echo "Starting Tutorial Setup for: $TARGET_DIR"
echo "---------------------------------------------"

# Pre-flight
ensure_uv_installed

# Global Setup
init_workspace "$TARGET_DIR"
gen_gitignore
init_root_env "$ROOT_PYTHON" "$ROOT_PYTHON_RANGE" "${ROOT_DEPS[@]}"

echo "---------------------------------------------"
echo "Setup complete! Your architecture is successfully built."
if [ "$TARGET_DIR" != "." ]; then
    echo "To explore the project: cd $TARGET_DIR"
fi