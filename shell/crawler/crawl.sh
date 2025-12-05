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
	ts=$(date +%Y%m%d_%H%M%S)

done < "$urls"

