#!/usr/bin/env bash

###############################################
#
# Title:       avl-lint-scripts.sh
# Author:      Arne Van Looveren
# Description: Linting script for scripts repository
# Usage:       avl-lint-scripts.sh
#
###############################################

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

