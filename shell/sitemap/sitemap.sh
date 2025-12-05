#!/bin/bash

### this script depends on ripgrep, please make sure you have it.

sm=()
cm_sm_path=("/sitemap.xml" "/sitemap_index.xml" "/sitemap-index.xml")

gdomain() {
    echo "$1" | sed -E 's|^https?://([^/]+).*|\1|'
}

fsm() {
    local dm=$1
    
    local res=$(curl -sL -w '\n%{url_effective}' "https://$dm/robots.txt")
    fdm=$(gdomain "$(echo "$res" | tail -1)")
    
    local robots=$(echo "$res" | head -n -1 | tr -d '\r' | rg -i "^sitemap:" | awk '{print $2}')
    
    if [[ -n "$robots" ]]; then
        while IFS= read -r sitemap; do
            sm+=("$sitemap")
            smrecur "$sitemap"
        done <<< "$robots"

    else
        echo "No sitemap found in robots.txt, checking common paths." >&2
        
        for path in "${cm_sm_path[@]}"; do
            echo "Checking: https://$dm$path" >&2
            
            if curl -sLf "https://$dm$path" >/dev/null 2>&1; then
                sm+=("https://$fdm$path")
                smrecur "https://$fdm$path"
                break
            fi
        done
    fi
}

smrecur() {
    local smurl=$1
    echo "Finding sitemaps in: $smurl" >&2
    local nst=$(curl -sL "$smurl" | rg -oP '(?<=<loc>)[^<]+\.xml(\.gz)?(?=</loc>)')
    for url in $nst; do
        if [[ ! " ${sm[@]} " =~ " ${url} " ]]; then
            sm+=("$url")
            smrecur "$url"
        fi
    done
}

xturls() {
    local smurl=$1
    echo "Extracting URLs from: $smurl" >&2
    curl -sL "$smurl" | rg -oP '(?<=<loc>)[^<]+(?=</loc>)'
}

