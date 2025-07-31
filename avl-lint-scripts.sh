#!/usr/bin/env bash

###############################################
#
# Title:       avl-lint-scripts.sh
# Author:      Arne Van Looveren
# Description: Linting script for scripts repository
#
# Usage:       avl-lint-scripts.sh
#
###############################################

if ! command -v shellcheck &> /dev/null; then
    echo "shellcheck could not be found. Please install it to run this script."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

FAILURE=0

while read -r file; do
    echo "Linting $file"
    if ! shellcheck --color=always -S warning "$file"; then
        echo "Linting failed for $file"
        FAILURE=1
    fi
done < <(find . -type f ! -path "./.git/*" ! -path "./.github/*")

if [[ $FAILURE -ne 0 ]]; then
    echo
    echo "Linting failed for one or more files."
    exit 1
else
    echo
    echo "All files passed linting."
    exit 0
fi

