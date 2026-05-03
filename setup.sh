#!/usr/bin/env bash
set -Eeuo pipefail

readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${BASE_DIR}/lib/helpers.sh"
source "${BASE_DIR}/lib/nginx.sh"
source "${BASE_DIR}/lib/ssl.sh"
source "${BASE_DIR}/lib/deploy.sh"

on_error() {
    local line_no="${1:-unknown}"
    local exit_code="${2:-1}"
    error "Setup failed on line ${line_no} (exit code: ${exit_code})."
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        die "Please run setup as root (or use sudo)."
    fi
}

prompt_project_type() {
    local input=""

    while true; do
        read_prompt "Project Type (laravel/react/node)" input
        input="${input,,}"

        case "${input}" in
            laravel|react|node)
                PROJECT_TYPE="${input}"
                return 0
                ;;
            *)
                warn "Invalid project type. Use: laravel, react, or node."
                ;;
        esac
    done
}

prompt_domain() {
    local input=""
    local domain_regex='^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,63}$'

    while true; do
        read_prompt "Domain Name (example.com)" input
        input="${input,,}"

        if [[ "${input}" =~ ${domain_regex} ]]; then
            DOMAIN="${input}"
            return 0
        fi

        warn "Invalid domain format. Example: app.example.com"
    done
}

prompt_project_path() {
    local input=""

    while true; do
        read_prompt "Project Path (/var/www/example)" input

        if [[ "${input}" != /* ]]; then
            warn "Project path must be an absolute path starting with '/'."
            continue
        fi

        PROJECT_PATH="${input%/}"
        [[ -n "${PROJECT_PATH}" ]] || PROJECT_PATH="/"
        return 0
    done
}

prompt_port() {
    local input=""
    local port_regex='^[0-9]+$'

    while true; do
        read_prompt "Port Number (1-65535)" input

        if [[ "${input}" =~ ${port_regex} ]]; then
            local port_num="${input#0}"
            if (( port_num >= 1 && port_num <= 65535 )); then
                PORT="${port_num}"
                return 0
            fi
        fi

        warn "Invalid port number. Please enter a number between 1 and 65535."
    done
}

main() {
    trap 'on_error ${LINENO} $?' ERR

    require_root
    banner

    prompt_project_type
    prompt_domain
    prompt_project_path
    if [[ "${PROJECT_TYPE}" == "node" ]]; then
        prompt_port
    fi

    deploy_project "${PROJECT_TYPE}" "${PROJECT_PATH}"
    create_nginx_config "${PROJECT_TYPE}" "${DOMAIN}" "${PROJECT_PATH}"
    enable_site "${DOMAIN}"
    reload_nginx
    install_ssl "${DOMAIN}"

    success "Website setup completed successfully."
}

main "$@"
