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
    local options=("laravel" "react" "node")
    local selected_index=0
    local key=""
    local i=0

    init_tty

    printf 'Project Type (use up/down arrow, Enter to select):\n' >&"${TTY_FD}"

    while true; do
        for i in "${!options[@]}"; do
            if (( i == selected_index )); then
                printf '  > %s\n' "${options[$i]}" >&"${TTY_FD}"
            else
                printf '    %s\n' "${options[$i]}" >&"${TTY_FD}"
            fi
        done

        if ! IFS= read -r -s -n1 -u "${TTY_FD}" key; then
            printf '\n' >&"${TTY_FD}"
            die "Input cancelled."
        fi

        case "${key}" in
            "")
                PROJECT_TYPE="${options[$selected_index]}"
                printf 'Selected project type: %s\n' "${PROJECT_TYPE}" >&"${TTY_FD}"
                return 0
                ;;
            $'\x1b')
                if IFS= read -r -s -n1 -u "${TTY_FD}" key && [[ "${key}" == "[" ]]; then
                    if IFS= read -r -s -n1 -u "${TTY_FD}" key; then
                        case "${key}" in
                            A)
                                selected_index=$(( (selected_index - 1 + ${#options[@]}) % ${#options[@]} ))
                                ;;
                            B)
                                selected_index=$(( (selected_index + 1) % ${#options[@]} ))
                                ;;
                        esac
                    fi
                fi
                ;;
        esac

        printf '\033[%dA' "${#options[@]}" >&"${TTY_FD}"
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

port_listening() {
    local target_port="$1"

    if command -v ss >/dev/null 2>&1; then
        ss -H -ltn 2>/dev/null | awk -v p="${target_port}" '
            {
                n = split($4, parts, ":")
                port = parts[n]
                gsub(/[^0-9]/, "", port)
                if (port == p) {
                    found = 1
                    exit
                }
            }
            END { exit(found ? 0 : 1) }
        '
        return $?
    fi

    if command -v lsof >/dev/null 2>&1; then
        lsof -nP -iTCP:"${target_port}" -sTCP:LISTEN >/dev/null 2>&1
        return $?
    fi

    return 1
}

show_used_ports_in_range() {
    local start_port="$1"
    local end_port="$2"
    local used_ports=()

    if command -v ss >/dev/null 2>&1; then
        mapfile -t used_ports < <(
            ss -H -ltn 2>/dev/null | awk -v start="${start_port}" -v end="${end_port}" '
                {
                    n = split($4, parts, ":")
                    port = parts[n]
                    gsub(/[^0-9]/, "", port)
                    if (port ~ /^[0-9]+$/ && port >= start && port <= end) {
                        print port
                    }
                }
            ' | sort -n -u
        )
    elif command -v lsof >/dev/null 2>&1; then
        mapfile -t used_ports < <(
            lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null \
                | awk -v start="${start_port}" -v end="${end_port}" 'NR > 1 {
                    n = split($9, parts, ":")
                    port = parts[n]
                    gsub(/[^0-9]/, "", port)
                    if (port ~ /^[0-9]+$/ && port >= start && port <= end) {
                        print port
                    }
                }' | sort -n -u
        )
    fi

    if (( ${#used_ports[@]} > 0 )); then
        info "Used ports (${start_port}-${end_port}): ${used_ports[*]}"
    else
        info "No used ports found in ${start_port}-${end_port}."
    fi
}

prompt_port() {
    local input=""
    local port_regex='^[0-9]+$'
    local preferred_start=5000
    local preferred_end=5100

    show_used_ports_in_range "${preferred_start}" "${preferred_end}"

    while true; do
        read_prompt "Port Number (1-65535)" input

        if [[ "${input}" =~ ${port_regex} ]]; then
            local port_num="${input#0}"
            if (( port_num >= 1 && port_num <= 65535 )); then
                if port_listening "${port_num}"; then
                    warn "Port ${port_num} is already in use. Please choose a different port."
                    continue
                fi
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
