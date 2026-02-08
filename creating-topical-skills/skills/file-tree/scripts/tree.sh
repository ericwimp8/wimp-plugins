#!/bin/bash

# File tree script - writes flat list of paths to an output file
# Usage: ./tree.sh <directory> <output-file> [--ignore "pattern1,pattern2"] [--type "ext"]

set -e

DIR=""
OUTPUT_FILE=""
IGNORE_PATTERNS=""
FILE_TYPE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ignore)
            IGNORE_PATTERNS="$2"
            shift 2
            ;;
        --type)
            FILE_TYPE="$2"
            shift 2
            ;;
        *)
            if [[ -z "$DIR" ]]; then
                DIR="$1"
            elif [[ -z "$OUTPUT_FILE" ]]; then
                OUTPUT_FILE="$1"
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$DIR" || -z "$OUTPUT_FILE" ]]; then
    echo "Usage: $0 <directory> <output-file> [--ignore \"pattern1,pattern2\"] [--type \"ext\"]" >&2
    exit 1
fi

if [[ ! -d "$DIR" ]]; then
    echo "Error: '$DIR' is not a directory" >&2
    exit 1
fi

# Normalize file type (remove leading dot if present)
if [[ -n "$FILE_TYPE" ]]; then
    FILE_TYPE="${FILE_TYPE#.}"
fi

# Build find arguments as an array (avoids eval and quoting issues)
FIND_ARGS=("$DIR")

# Add prune expressions for ignore patterns
if [[ -n "$IGNORE_PATTERNS" ]]; then
    IFS=',' read -ra PATTERNS <<< "$IGNORE_PATTERNS"
    FIND_ARGS+=("(")
    first=true
    for pattern in "${PATTERNS[@]}"; do
        pattern=$(echo "$pattern" | xargs)  # trim whitespace
        if [[ -z "$pattern" ]]; then
            continue
        fi
        if [[ "$first" != true ]]; then
            FIND_ARGS+=("-o")
        fi
        FIND_ARGS+=("-name" "$pattern")
        first=false
    done
    FIND_ARGS+=(")" "-prune" "-o")
fi

# Add type filter
if [[ -n "$FILE_TYPE" ]]; then
    FIND_ARGS+=("-type" "f" "-name" "*.$FILE_TYPE" "-print")
else
    FIND_ARGS+=("(" "-type" "f" "-o" "-type" "d" ")" "-print")
fi

# Execute, sort, and write to output file
find "${FIND_ARGS[@]}" | sort > "$OUTPUT_FILE"
