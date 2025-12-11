#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------
# Local Bootstrap Script (macOS)
# Installs required tooling
# ---------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function header() {
    echo ""
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

function ensure_command() {
    local cmd="$1"
    local brew_pkg="$2"

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "[OK] $cmd already installed: $(command -v "$cmd")"
    else
        echo "[INSTALL] $cmd not found. Installing $brew_pkg..."
        brew install "$brew_pkg"
    fi
}

function ensure_terraform() {
    if command -v terraform >/dev/null 2>&1; then
        echo "[OK] terraform already installed: $(command -v terraform)"
        return 0
    fi

    echo "[INSTALL] terraform not found. Installing via hashicorp/tap..."
    brew tap hashicorp/tap || true
    brew install hashicorp/tap/terraform
}

function ensure_docker() {
    installer="$SCRIPT_DIR/install-docker-desktop.sh"
    if [[ ! -x "$installer" ]]; then
        echo "[ERROR] $installer is missing or not executable."
        exit 1
    fi
    "$installer"
}

header "Checking Homebrew"
if ! command -v brew >/dev/null 2>&1; then
    echo "[ERROR] Homebrew is not installed."
    echo "Install it first using:"
    # shellcheck disable=SC2016
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

header "Installing Required Tools"

ensure_docker
ensure_command kind "kind"
ensure_command helm "helm"
ensure_command aws "awscli"
ensure_terraform

header "Verifying Versions"

docker --version || true
kubectl version --client || true
kind version || true
helm version || true
terraform version || true
aws --version || true

header "Bootstrap Complete"
echo "Your local environment is ready."
