#!/usr/bin/env bash

deploy_project() {
    local project_type="$1"
    local project_path="$2"

    if [[ -z "${project_path}" ]]; then
        die "Project path is empty."
    fi

    mkdir -p "${project_path}"

    if [[ "${project_type}" == "laravel" ]]; then
        mkdir -p "${project_path}/storage" "${project_path}/bootstrap/cache"
        chmod -R 775 "${project_path}/storage" "${project_path}/bootstrap/cache"
    fi

    success "Project directory prepared: ${project_path}"
}
