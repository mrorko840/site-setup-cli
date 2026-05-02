#!/usr/bin/env bash
set -Eeuo pipefail

readonly REPO_URL="https://github.com/mrorko840/site-setup-cli.git"
readonly INSTALL_DIR="/opt/site-setup-cli"

on_error() {
    local line_no="${1:-unknown}"
    printf '[ERROR] Installer failed on line %s.\n' "$line_no" >&2
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        printf '[ERROR] Please run as root (or use sudo).\n' >&2
        exit 1
    fi
}

install_dependencies() {
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y git curl wget nginx certbot python3-certbot-nginx
}

main() {
    trap 'on_error ${LINENO}' ERR
    require_root

    printf '[INFO] Installing Site Setup CLI...\n'
    install_dependencies

    rm -rf "${INSTALL_DIR}"
    git clone --depth 1 "${REPO_URL}" "${INSTALL_DIR}"

    chmod +x "${INSTALL_DIR}/install.sh"
    chmod +x "${INSTALL_DIR}/setup.sh"
    chmod +x "${INSTALL_DIR}/lib/"*.sh

    cd "${INSTALL_DIR}"
    bash ./setup.sh
}

main "$@"
