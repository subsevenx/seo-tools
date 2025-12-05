#!/bin/bash

urls=$1
odir=$2

if [[ ! -f "$urls" ]] || [[ -z "$odir" ]]; then
    echo "Usage: $0 <urls_list.txt> <output_dir>" >&2
    exit 1
fi

mkdir -p "$odir"
