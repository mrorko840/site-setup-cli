#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

create_nginx_config() {
    TYPE=$1
    DOMAIN=$2
    PATHDIR=$3

    TEMPLATE="$BASE_DIR/templates/$TYPE.conf"
    TARGET="/etc/nginx/sites-available/$DOMAIN"

    [ -f "$TEMPLATE" ] || exit 1

    sed \
        -e "s|{{DOMAIN}}|$DOMAIN|g" \
        -e "s|{{ROOT_PATH}}|$PATHDIR|g" \
        "$TEMPLATE" > "$TARGET"

    echo "Nginx config created."
}

enable_site() {
    DOMAIN=$1

    ln -sf "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-enabled/$DOMAIN"
}

reload_nginx() {
    nginx -t
    systemctl reload nginx
}