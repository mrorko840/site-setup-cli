#!/usr/bin/env bash

create_nginx_config() {
    local project_type="$1"
    local domain="$2"
    local project_path="$3"
    local template="${BASE_DIR}/templates/${project_type}.conf"
    local target="/etc/nginx/sites-available/${domain}"

    if [[ ! -f "${template}" ]]; then
        die "Nginx template not found: ${template}"
    fi

    sed \
        -e "s|{{DOMAIN}}|${domain}|g" \
        -e "s|{{ROOT_PATH}}|${project_path}|g" \
        "${template}" > "${target}"

    success "Nginx config created: ${target}"
}

enable_site() {
    local domain="$1"
    local source="/etc/nginx/sites-available/${domain}"
    local target="/etc/nginx/sites-enabled/${domain}"

    ln -sfn "${source}" "${target}"
    success "Site enabled: ${domain}"
}

reload_nginx() {
    nginx -t
    systemctl reload nginx
    success "Nginx reloaded."
}
