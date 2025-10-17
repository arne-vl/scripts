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

# Check dependencies: tmux and fzf
check_dependencies() {
    for cmd in tmux fzf; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "$cmd could not be found. Please install it to run this script." >&2
            exit 1
        fi
    done
}

# Return list of tmux sessions excluding current session (if inside tmux)
list_sessions() {
    local CURRENT_SESSION=""
    if [ -n "$TMUX" ]; then
        CURRENT_SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    fi

    tmux list-sessions 2>/dev/null | cut -d: -f1 | grep -vx "$CURRENT_SESSION"
}

# Print all sessions or a message if none exist
list_command() {
    local SESSIONS
    SESSIONS=$(tmux list-sessions 2>/dev/null | cut -d: -f1)
    if [ -z "$SESSIONS" ]; then
        echo "No tmux sessions found." >&2
    else
        echo "$SESSIONS"
    fi
}

# Kill a session by name
kill_session() {
    local SESSION_NAME="$1"
    if [ -z "$SESSION_NAME" ]; then
        echo "Usage: $0 kill <session-name>" >&2
        exit 1
    fi

    if tmux list-sessions 2>/dev/null | cut -d: -f1 | grep -qx "$SESSION_NAME"; then
        tmux kill-session -t "$SESSION_NAME"
        echo "Killed session '$SESSION_NAME'."
    else
        echo "Session '$SESSION_NAME' does not exist." >&2
        exit 1
    fi
}

# Attach or create (and switch) session as needed
attach_or_create_session() {
    local SESSION_NAME="$1"

    # Check if session exists
    if tmux list-sessions 2>/dev/null | cut -d: -f1 | grep -qx "$SESSION_NAME"; then
        if [ -n "$TMUX" ]; then
            # Inside tmux: switch client to existing session
            tmux switch-client -t "$SESSION_NAME"
        else
            # Outside tmux: attach to existing session
            tmux attach-session -t "$SESSION_NAME"
        fi
    else
        if [ -n "$TMUX" ]; then
            # Inside tmux: create detached session and switch to it (no nesting)
            tmux new-session -d -s "$SESSION_NAME"
            tmux switch-client -t "$SESSION_NAME"
        else
            # Outside tmux: create new session and attach
            tmux new-session -s "$SESSION_NAME"
        fi
    fi
}

# Main script logic

check_dependencies

case "$1" in
    list|l)
        list_command
        exit 0
        ;;
    kill|k)
        kill_session "$2"
        exit 0
        ;;
    *)
        ;;
esac

if [ -n "$1" ]; then
    SESSION_NAME="$1"
else
    SESSIONS=$(list_sessions)
    if [ -z "$SESSIONS" ]; then
        echo "No tmux sessions found." >&2
        exit 0
    fi
    SESSION_NAME=$(echo "$SESSIONS" | fzf --height=40% --border-label=' tmux manager ' --preview='tmux list-windows -t {}') || exit 0
fi

attach_or_create_session "$SESSION_NAME"

