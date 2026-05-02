#!/usr/bin/env bash

if [[ -n "${SITE_SETUP_HELPERS_LOADED:-}" ]]; then
    return 0 2>/dev/null || exit 0
fi
SITE_SETUP_HELPERS_LOADED=1

TTY_FD=""

banner() {
    if [[ -t 1 ]]; then
        clear
    fi

    printf '==================================\n'
    printf '   Site Setup CLI by Hemel\n'
    printf '==================================\n'
}

info() {
    printf '[INFO] %s\n' "$1"
}

warn() {
    printf '[WARN] %s\n' "$1" >&2
}

success() {
    printf '[OK] %s\n' "$1"
}

error() {
    printf '[ERROR] %s\n' "$1" >&2
}

die() {
    error "$1"
    exit 1
}

init_tty() {
    if [[ -n "${TTY_FD}" ]]; then
        return 0
    fi

    if [[ -t 0 && -t 1 ]]; then
        TTY_FD=0
        return 0
    fi

    if [[ -r /dev/tty && -w /dev/tty ]]; then
        exec 3<>/dev/tty
        TTY_FD=3
        return 0
    fi

    die "No interactive terminal found. Please run this in a real terminal."
}

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

read_prompt() {
    local prompt="$1"
    local output_var="$2"
    local value=""

    init_tty

    while true; do
        printf '%s: ' "$prompt" >&"${TTY_FD}"
        if ! IFS= read -r -u "${TTY_FD}" value; then
            printf '\n' >&"${TTY_FD}"
            die "Input cancelled."
        fi

        value="$(trim "$value")"
        if [[ -n "${value}" ]]; then
            printf -v "${output_var}" '%s' "${value}"
            return 0
        fi

        warn "Value cannot be empty. Please try again."
    done
}
