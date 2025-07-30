#!/bin/bash

###############################################
#
# Title:       tm
# Author:      Arne Van Looveren
# Description: Tmux Manager
#
# Usage:       tm [session_name]
# Usage:       tm kill [session_name]
# Usage:       tm list
#
###############################################
#
# Note:
# This script needs tmux and fzf to be installed.
#
###############################################

if ! command -v tmux &> /dev/null; then
    echo "tmux could not be found. Please install it to run this script."
    exit 1
fi

if ! command -v fzf &> /dev/null; then
    echo "fzf could not be found. Please install it to run this script."
    exit 1
fi

list_sessions() {
    tmux list-sessions 2>/dev/null | cut -d: -f1
}

if [[ "$1" == "list" ]]; then
    if ! list_sessions | tee /dev/stderr | grep -q '.'; then
      echo "No tmux sessions found." >&2
    fi
    exit 0
fi

if [[ "$1" == "kill" ]]; then
    SESSION_NAME="$2"
    if [[ -z "$SESSION_NAME" ]]; then
        echo "Usage: $0 kill <session-name>" >&2
        exit 1
    fi

    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux kill-session -t "$SESSION_NAME"
        echo "Killed session '$SESSION_NAME'"
    else
        echo "Session '$SESSION_NAME' does not exist." >&2
    fi
    exit 0
fi

if [[ -n "$1" ]]; then
    SESSION_NAME="$1"
else
    SESSION_NAME=$(list_sessions | fzf --height=40% --reverse --border-label=' tmux manager ') || exit 0
fi

if tmux list-sessions 2>/dev/null | cut -d: -f1 | grep -qx "$SESSION_NAME"; then
    tmux attach-session -t "$SESSION_NAME"
else
    tmux new-session -s "$SESSION_NAME"
fi

