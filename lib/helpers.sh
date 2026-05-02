#!/bin/bash

banner() {
    clear
    echo "=================================="
    echo "   Site Setup CLI by Hemel"
    echo "=================================="
}

ask() {
    local prompt="$1"
    local value

    read -r -p "$prompt: " value
    printf '%s' "$value"
}

success() {
    echo "✅ $1"
}

error() {
    echo "❌ $1"
    exit 1
}