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

	fn=$(echo "$url" | sed 's|https\?://||; s|[^a-zA-Z0-9]|_|g')

	if ! content=$(timeout 30 w3m -dump "$url" 2>/dev/null); then
		echo "Failed: $url" >&2
		continue
	fi

	echo "$content" | tr '\n' ' ' | tr -s ' ' > "${odir}/${fn}_${ts}.txt"
done < "$urls"

