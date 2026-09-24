#!/usr/bin/env bash

SBX_KITS="${SBX_KITS:-$DOTFILES_PATH/llm}"
SBX_DEFAULT="${SBX_DEFAULT:-vibe}"

# llm [-n] [harness]
#
# Opens a sandbox for the current project, creating one if none exists.
# If several exist, asks which one. -n always creates a new one.
# Outside a git repo, asks before creating one for the current directory.
#
# Sandboxes are named <harness>-<project>, then <harness>-<project>-2, -3...
llm() {
    local force_new=false
    if [ "$1" = "-n" ]; then
        force_new=true
        shift
    fi
    local harness=$1

    # The git repo root, or the current directory when not in a repo.
    local workspace project in_repo=true
    if ! workspace=$(git rev-parse --show-toplevel 2>/dev/null); then
        workspace=$PWD
        in_repo=false
    fi
    project=$(basename "$workspace")

    local existing=($(_sbx_list "$project" "$harness"))

    local sandbox is_new=false
    if $force_new || [ ${#existing[@]} -eq 0 ]; then
        sandbox=$(_sbx_free_name "${harness:-$SBX_DEFAULT}-$project" "${existing[@]}")
        is_new=true
    elif [ ${#existing[@]} -eq 1 ]; then
        sandbox=${existing[0]}
    else
        # Numbered menu; re-asks on invalid input, gives up on Ctrl-D.
        local PS3="Sandbox: "
        select sandbox in "${existing[@]}"; do
            [ -n "$sandbox" ] && break
        done
        [ -n "$sandbox" ] || return 1
    fi

    # Strip "-<project>" and any "-<n>" after it.
    harness=${sandbox%-"$project"*}

    local kit=()
    if [ -f "$SBX_KITS/$harness/spec.yaml" ]; then
        kit=(--kit "$SBX_KITS/$harness")
    fi

    if $is_new; then
        if ! $in_repo; then
            local answer
            read -r -p "Not a git repo. Create a sandbox for $workspace? [y/N] " answer
            [[ $answer == [yY]* ]] || return 1
        fi
        sbx create --name "$sandbox" "${kit[@]}" "$harness" "$workspace" || return 1
    fi
    sbx run "${kit[@]}" --name "$sandbox"
}

# Sandboxes of this project, optionally only those of one harness.
_sbx_list() {
    local project=$1 harness=$2 name
    sbx ls 2>/dev/null | while read -r name _; do
        if [[ $name =~ ^(.+)-"$project"(-[0-9]+)?$ ]]; then
            if [ -z "$harness" ] || [ "${BASH_REMATCH[1]}" = "$harness" ]; then
                echo "$name"
            fi
        fi
    done
}

# First of <base>, <base>-2, <base>-3... that isn't already taken.
_sbx_free_name() {
    local base=$1
    shift
    local candidate=$base n=1
    while _sbx_contains "$candidate" "$@"; do
        n=$((n + 1))
        candidate="$base-$n"
    done
    echo "$candidate"
}

# Is the first argument one of the others?
_sbx_contains() {
    local needle=$1 item
    shift
    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done
    return 1
}
