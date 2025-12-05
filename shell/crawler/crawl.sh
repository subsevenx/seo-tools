#!/bin/bash

urls=$1

while IFS= read -r url; do
	w3m -dump "$url"
done < "$urls"
