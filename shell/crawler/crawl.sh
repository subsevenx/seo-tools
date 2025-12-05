#!/bin/bash

urls="$1"
odir="$2"

if [[ ! -f "$urls" ]] || [[ -z "$odir" ]]; then
    echo "Usage: $0 <urls_list.txt> <output_dir>" >&2
    exit 1
fi

mkdir -p "$odir"

while IFS= read -r url || [[ -n "$url" ]]; do
    echo "Crawling: $url"
    [[ -z "$url" ]] && continue
    
    fn=$(echo "$url" | sed 's|https\?://||; s|[^a-zA-Z0-9]|_|g')
    
    if ! content=$(timeout 30 w3m -dump_source "$url" -o accept_encoding='identity;q=0' 2>/dev/null); then
        echo "Failed: $url" >&2
        continue
    fi
    
    if ! echo "$content" | file -b --mime-type - | grep -q 'html'; then
        echo "Skipping non-HTML: $url" >&2
        continue
    fi
    
    echo "$content" | tr '\n\t' ' ' | tr -s ' ' | sed 's/> *</></g' > "${odir}/${fn}.html" > "${odir}/${fn}.html"
done < "$urls"

