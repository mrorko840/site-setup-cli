#!/usr/bin/env bash

install_ssl() {
    local domain="$1"
    local email="admin@${domain}"

    if certbot --nginx -d "${domain}" --non-interactive --agree-tos -m "${email}"; then
        success "SSL installed for ${domain}"
    else
        warn "Certbot failed for ${domain}. You can retry manually later."
    fi
}
