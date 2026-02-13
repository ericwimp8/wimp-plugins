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
# Supported ignore styles:
# - Basename match: "node_modules" (matches any directory/file with that name)
# - Relative path match: "ios/Pods" (matches only that path under DIR)
if [[ -n "$IGNORE_PATTERNS" ]]; then
    IFS=',' read -ra PATTERNS <<< "$IGNORE_PATTERNS"
    IGNORE_ARGS=()
    ignore_count=0
    for pattern in "${PATTERNS[@]}"; do
        pattern=$(echo "$pattern" | xargs)  # trim whitespace
        if [[ -z "$pattern" ]]; then
            continue
        fi

        if [[ "$ignore_count" -gt 0 ]]; then
            IGNORE_ARGS+=("-o")
        fi

        if [[ "$pattern" == */* ]]; then
            if [[ "$pattern" == /* ]]; then
                path_pattern="$pattern"
            else
                path_pattern="${pattern#./}"
                path_pattern="${path_pattern#/}"
                path_pattern="$DIR/$path_pattern"
            fi
            IGNORE_ARGS+=("(" "-path" "$path_pattern" "-o" "-path" "$path_pattern/*" ")")
        else
            IGNORE_ARGS+=("-name" "$pattern")
        fi
        ignore_count=$((ignore_count + 1))
    done

    if [[ "$ignore_count" -gt 0 ]]; then
        FIND_ARGS+=("(" "${IGNORE_ARGS[@]}" ")" "-prune" "-o")
    fi
fi

# Add type filter
if [[ -n "$FILE_TYPE" ]]; then
    FIND_ARGS+=("-type" "f" "-name" "*.$FILE_TYPE" "-print")
else
    FIND_ARGS+=("(" "-type" "f" "-o" "-type" "d" ")" "-print")
fi

# Execute, sort, and write to output file
find "${FIND_ARGS[@]}" | sort > "$OUTPUT_FILE"
