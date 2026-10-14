# ============================================================
#
# A helper function to launch sbx run with different harnesses
function _sbx_run_kit() {
    local prefix=$1
    local kit_path=$2
    local arg=${3:-$PWD}

    if [ -d "$arg" ]; then
        local dir=$(realpath "$arg")
        local name="$prefix-$(basename "$dir")"

        if sbx ls -q | grep -qx "$name"; then
            sbx run --name "$name"
        else
            sbx run "$kit_path" --name "$name" "$dir"
        fi
    else
        echo "$arg is not a directory."
    fi
}


# Vibe sandbox
function vibe() {
    _sbx_run_kit vibe "$DOTFILES_PATH/llm/vibe/" "$@"
}


# Pi sandbox
function pi() {
    _sbx_run_kit pi "$DOTFILES_PATH/llm/pi/" "$@"
}


# ============================================================
#
# Vibe code: create a worktree and launch a sandbox in it
# Usage: vc [harness] <feature>
#   vc my-feature       → vibe harness, branch feat/my-feature
#   vc pi my-feature    → pi harness, branch feat/my-feature
function vc() {
    local harness="vibe"
    local feature=""

    case $# in
        1) feature="$1" ;;
        2) harness="$1"; feature="$2" ;;
        *) echo "Usage: vc [harness] <feature>"; return 1 ;;
    esac

    feature=$(printf '%s' "$feature" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-z0-9\/-]/-/g' \
        | sed 's/-\+/-/g' \
        | sed 's/^-\+//;s/-\+$//')

    case "$feature" in
        feat/*) ;;
        *) feature="feat/$feature" ;;
    esac

    if ! git check-ref-format --branch "$feature" 2>/dev/null; then
        echo "vc: invalid feature name '$feature'"
        return 1
    fi

    local repo_root worktree_name worktree_path
    repo_root=$(git rev-parse --show-toplevel)
    worktree_name=$(printf '%s' "$feature" | tr '/' '-')
    worktree_path="$repo_root/../$worktree_name"

    if [ -d "$worktree_path" ]; then
        echo "vc: reusing worktree $worktree_path"
    elif git -C "$repo_root" show-ref --verify --quiet "refs/heads/$feature"; then
        git -C "$repo_root" worktree add "$worktree_path" "$feature" || return 1
    else
        git -C "$repo_root" worktree add -b "$feature" "$worktree_path" || return 1
    fi

    _sbx_run_kit "$harness" "$DOTFILES_PATH/llm/$harness/" "$worktree_path"
}
