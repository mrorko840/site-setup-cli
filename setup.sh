#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$BASE_DIR/lib/helpers.sh"
source "$BASE_DIR/lib/nginx.sh"
source "$BASE_DIR/lib/ssl.sh"
source "$BASE_DIR/lib/deploy.sh"

banner

read -r -p "Project Type (laravel/react/node): " PROJECT_TYPE
read -r -p "Domain Name: " DOMAIN
read -r -p "Project Path (/var/www/example): " PROJECT_PATH

[ -z "$PROJECT_TYPE" ] && exit 1
[ -z "$DOMAIN" ] && exit 1
[ -z "$PROJECT_PATH" ] && exit 1

deploy_project "$PROJECT_TYPE" "$PROJECT_PATH"
create_nginx_config "$PROJECT_TYPE" "$DOMAIN" "$PROJECT_PATH"
enable_site "$DOMAIN"
reload_nginx
install_ssl "$DOMAIN"

success "Website setup completed successfully."