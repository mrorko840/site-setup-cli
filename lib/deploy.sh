#!/bin/bash

deploy_project() {
    TYPE=$1
    PATHDIR=$2

    mkdir -p "$PATHDIR"

    if [ "$TYPE" = "laravel" ]; then
        chmod -R 775 "$PATHDIR/storage" "$PATHDIR/bootstrap/cache" 2>/dev/null || true
    fi

    echo "Project prepared."
}