#!/bin/bash

# File tree script - outputs flat list of paths
# Usage: ./tree.sh <directory> [--ignore "pattern1,pattern2"] [--type "ext"]

set -e

DIR=""
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
            fi
            shift
            ;;
    esac
done

# Validate directory
if [[ -z "$DIR" ]]; then
    echo "Usage: $0 <directory> [--ignore \"pattern1,pattern2\"] [--type \"ext\"]" >&2
    exit 1
fi

# Normalize file type (remove leading dot if present)
if [[ -n "$FILE_TYPE" ]]; then
    FILE_TYPE="${FILE_TYPE#.}"
fi

if [[ ! -d "$DIR" ]]; then
    echo "Error: '$DIR' is not a directory" >&2
    exit 1
fi

# Build find command with ignore patterns and type filter
if [[ -n "$FILE_TYPE" ]]; then
    TYPE_EXPR="-type f -name \"*.$FILE_TYPE\""
else
    TYPE_EXPR="-type f -o -type d"
fi

if [[ -n "$IGNORE_PATTERNS" ]]; then
    # Convert comma-separated patterns to find -prune expressions
    IFS=',' read -ra PATTERNS <<< "$IGNORE_PATTERNS"
    PRUNE_EXPR=""
    for pattern in "${PATTERNS[@]}"; do
        pattern=$(echo "$pattern" | xargs)  # trim whitespace
        if [[ -n "$PRUNE_EXPR" ]]; then
            PRUNE_EXPR="$PRUNE_EXPR -o"
        fi
        PRUNE_EXPR="$PRUNE_EXPR -name \"$pattern\""
    done
    FIND_CMD="find \"$DIR\" \\( $PRUNE_EXPR \\) -prune -o \\( $TYPE_EXPR \\) -print"
else
    FIND_CMD="find \"$DIR\" $TYPE_EXPR"
fi

# Execute and sort output
eval $FIND_CMD | sort
