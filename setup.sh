#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$BASE_DIR/lib/helpers.sh"
source "$BASE_DIR/lib/nginx.sh"
source "$BASE_DIR/lib/ssl.sh"
source "$BASE_DIR/lib/deploy.sh"

banner

PROJECT_TYPE=$(ask "Project Type (laravel/react/node)")
DOMAIN=$(ask "Domain Name")
PROJECT_PATH=$(ask "Project Path (/var/www/example)")

deploy_project "$PROJECT_TYPE" "$PROJECT_PATH"
create_nginx_config "$PROJECT_TYPE" "$DOMAIN" "$PROJECT_PATH"
enable_site "$DOMAIN"
reload_nginx
install_ssl "$DOMAIN"

success "Website setup completed successfully."