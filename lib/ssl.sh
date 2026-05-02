#!/bin/bash

install_ssl() {
    DOMAIN=$1
    certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m admin@"$DOMAIN" || true
}