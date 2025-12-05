#!/bin/bash

md="html"
w3mopt=""

while getopts "m:w:" opt; do
    case $opt in
        m) md="$OPTARG" ;;
        w) w3mopt="$OPTARG" ;;
        *) echo "Usage: $0 [-m html|text] [-w 'w3m_options'] <urls_list.txt> <output_dir>" >&2; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

urls="$1"
odir="$2"

if [[ ! "$md" =~ ^(html|text)$ ]] || [[ ! -f "$urls" ]] || [[ -z "$odir" ]]; then
    echo "Usage: $0 [-m html|text] [-w 'w3m_options'] <urls_list.txt> <output_dir>" >&2
    exit 1
fi

mkdir -p "$odir"

while IFS= read -r url || [[ -n "$url" ]]; do
    echo "Crawling: $url"
    [[ -z "$url" ]] && continue
    
    fn=$(echo "$url" | sed 's|https\?://||; s|[^a-zA-Z0-9]|_|g')
    
    if ! content=$(timeout 30 w3m -dump_source $w3mopt -o accept_encoding='identity;q=0' "$url" 2>/dev/null); then
        echo "Failed: $url" >&2
        continue
    fi
    
    if ! echo "$content" | file -b --mime-type - | grep -q 'html'; then
        echo "Skipping non-HTML: $url" >&2
        continue
    fi
    
    if [[ "$md" == "html" ]]; then
        echo "$content" | tr '\n\t' ' ' | tr -s ' ' | sed 's/> *</></g' > "${odir}/${fn}.html"
    else
        timeout 30 w3m -dump $w3mopt "$url" 2>/dev/null > "${odir}/${fn}.txt"
    fi
done < "$urls"