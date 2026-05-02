#!/bin/bash

banner() {
    clear
    echo "=================================="
    echo "   Site Setup CLI by Hemel"
    echo "=================================="
}

ask() {
    read -p "$1: " value
    echo "$value"
}

success() {
    echo "✅ $1"
}

error() {
    echo "❌ $1"
    exit 1
}