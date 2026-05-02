#!/bin/bash
set -euo pipefail

REPO="https://github.com/mrorko840/site-setup-cli.git"
DIR="/opt/site-setup-cli"

echo "🚀 Installing Site Setup CLI..."

apt update -y
apt install -y git curl wget nginx certbot python3-certbot-nginx

rm -rf "$DIR"
git clone "$REPO" "$DIR"

chmod +x "$DIR/install.sh"
chmod +x "$DIR/setup.sh"
chmod +x "$DIR/lib/"*.sh

cd "$DIR"
bash setup.sh