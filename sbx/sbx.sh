#!/usr/bin/env bash

SBX_KITS="${SBX_KITS:-$DOTFILES_PATH/sbx}"
SBX_DEFAULT="${SBX_DEFAULT:-vibe}"

# sandbox name: <harness>-<repo or dir>
_sbx_name() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) || root=$PWD
    echo "$1-$(basename "$root")"
}

# echoes "--kit <path>" for local kits, nothing for built-in agents
_sbx_kit() {
    [ -f "$SBX_KITS/$1/spec.yaml" ] && printf -- '--kit %s' "$SBX_KITS/$1"
}

# list what's available
sbls() {
    echo "kits:"
    for d in "$SBX_KITS"/*/spec.yaml; do
        [ -f "$d" ] && echo "  $(basename "$(dirname "$d")")"
    done
    echo "sandboxes:"
    sbx ls 2>/dev/null | sed 's/^/  /'
}

# sb [harness] [path]
sb() {
    local harness="${1:-$SBX_DEFAULT}"
    local path="${2:-.}"
    local name; name=$(_sbx_name "$harness")
    local kit; kit=$(_sbx_kit "$harness")

    if sbx ls 2>/dev/null | grep -q "\b$name\b"; then
        sbx run $kit --name "$name"
    else
        sbx create --name "$name" $kit "$harness" "$path" || return 1
        sbx run $kit --name "$name"
    fi

    [ -n "${SBX_QUIET:-}" ] && return

    cat <<EOF

sandbox: $name   harness: $harness

shell in     sbx exec $name -- bash
stop         sbx stop $name
remove       sbx rm $name
resume       sbr [harness]

EOF
}

# sbr [harness] — pick a session to resume
sbr() {
    local harness="${1:-$SBX_DEFAULT}"
    sbx run $(_sbx_kit "$harness") --name "$(_sbx_name "$harness")" -- --resume
}
