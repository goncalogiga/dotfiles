# Some functions to follow the workflows defined here :
# https://docs.docker.com/ai/sandboxes/workflows/git/


# ============================================================
#              Gitignored-file stashing
# ============================================================


# Sandboxes bind-mount the workspace, so gitignored files (decrypted/
# secrets, .venv, ...) are readable by the agent. Before launching, move
# them out of the workspace into a per-directory stash; they are restored
# when the sandbox exits. Disable with SBX_STASH_IGNORED=0.


function _sbx_stash_dir() {
    local root=${SBX_STASH_ROOT:-$HOME/.vibetrees/stash}
    local key=$(printf '%s' "$(realpath "$1")" | cksum | cut -d' ' -f1)
    echo "$root/$key"
}


# Move gitignored files out of the workspace
function _sbx_stash_ignored() {
    local dir=$1

    [ "${SBX_STASH_IGNORED:-1}" = "1" ] || return 0
    git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    local stash files
    stash=$(_sbx_stash_dir "$dir")
    files="$stash/files"

    case "$stash/" in
        "$dir"/*)
            echo "sbx: stash dir $stash is inside the workspace; refusing to launch" >&2
            echo "sbx: set SBX_STASH_ROOT outside the workspace, or SBX_STASH_IGNORED=0 to skip" >&2
            return 1
            ;;
    esac

    if [ -d "$stash/lock" ]; then
        echo "sbx: another session is already stashing ignored files for $dir" >&2
        echo "sbx: refusing to launch (gitignored files would be exposed)" >&2
        return 1
    fi

    if [ -d "$files" ]; then
        echo "sbx: recovering leftover stash for $dir"
        _sbx_restore_ignored "$dir" || return 1
    fi

    # mkdir is atomic: it doubles as the lock against concurrent launches
    mkdir -p "$stash" || return 1
    if ! mkdir "$stash/lock" 2>/dev/null; then
        echo "sbx: another session is already stashing ignored files for $dir" >&2
        echo "sbx: refusing to launch (gitignored files would be exposed)" >&2
        return 1
    fi

    if ! mkdir -p "$files"; then
        _sbx_restore_ignored "$dir"
        return 1
    fi

    local rel moved=0
    while IFS= read -r -d '' rel; do
        if ! mkdir -p "$files/$(dirname "$rel")" || ! mv "$dir/$rel" "$files/$rel"; then
            echo "sbx: failed to stash $rel; rolling back" >&2
            _sbx_restore_ignored "$dir"
            return 1
        fi
        moved=$((moved + 1))
    done < <(git -C "$dir" ls-files --others --ignored --exclude-standard -z)

    if [ "$moved" -gt 0 ]; then
        echo "sbx: stashed $moved gitignored file(s) from $dir (restored on exit)"
    fi
}


# Move stashed gitignored files back into the workspace
function _sbx_restore_ignored() {
    local dir=$1

    local stash files
    stash=$(_sbx_stash_dir "$dir")
    files="$stash/files"

    if [ -d "$files" ]; then
        local rel
        while IFS= read -r -d '' rel; do
            rel=${rel#"$files"/}
            if [ -e "$dir/$rel" ]; then
                echo "sbx: warning: $rel was recreated in the sandbox; stashed copy kept at $files/$rel" >&2
                continue
            fi
            mkdir -p "$dir/$(dirname "$rel")"
            mv "$files/$rel" "$dir/$rel"
        done < <(find "$files" \( -type f -o -type l \) -print0)

        find "$files" -depth -type d -empty -delete 2>/dev/null
    fi

    rmdir "$stash/lock" 2>/dev/null
    rmdir "$stash" 2>/dev/null
    return 0
}


# ============================================================
#                      Direct Mode
# ============================================================


# A helper function to launch sbx run with different harnesses
function _sbx_run_kit() {
    local prefix=$1
    local kit_path=$2
    local arg=${3:-$PWD}
    local custom_name=$4

    if [ -d "$arg" ]; then
        local dir=$(realpath "$arg")
        local name=${custom_name:-"$prefix-$(basename "$dir")"}

        _sbx_stash_ignored "$dir" || return 1

        # Safety net: restore the stash even if the shell exits mid-run.
        # (trap -p must be redirected to a file: $(...) runs in a subshell,
        # which resets traps and would lose a pre-existing EXIT trap.)
        local trap_file
        trap_file=$(mktemp)
        trap -p EXIT > "$trap_file"
        trap "_sbx_restore_ignored '$dir'" EXIT

        if sbx ls -q | grep -qx "$name"; then
            sbx run --name "$name"
        else
            sbx run "$kit_path" --name "$name" "$dir"
        fi
        local rc=$?

        _sbx_restore_ignored "$dir"
        if [ -s "$trap_file" ]; then
            eval "$(cat "$trap_file")"
        else
            trap - EXIT
        fi
        rm -f "$trap_file"
        return $rc
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
#                      Worktree mode
# ============================================================


# List existing feature sandboxes for a harness (harness and repo prefix stripped)
function _vibetree_list() {
    local harness="$1"
    local repo_name="$2"
    sbx ls -q 2>/dev/null | grep "^${harness}-${repo_name}-" | sed "s/^${harness}-${repo_name}-//" || true
}


# Create a worktree for a feature and launch a sandbox in it
function _vibetree_new() {
    local harness="$1"
    local feature="$2"

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
        echo "vibetree: invalid feature name '$feature'"
        return 1
    fi

    local repo_root repo_name worktree_name worktree_path
    repo_root=$(git rev-parse --show-toplevel) || { echo "vibetree: not in a git repository"; return 1; }
    repo_name=$(basename "$repo_root")
    worktree_name=$(printf '%s' "$feature" | tr '/' '-')
    worktree_path="$HOME/.vibetrees/$repo_name/$worktree_name"

    echo "vibetree: branch $feature"

    if [ -d "$worktree_path" ]; then
        echo "vibetree: reusing worktree ~/.vibetrees/$repo_name/$worktree_name"
    else
        mkdir -p "$HOME/.vibetrees/$repo_name"
        if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$feature"; then
            echo "vibetree: creating worktree ~/.vibetrees/$repo_name/$worktree_name (existing branch)"
            git -C "$repo_root" worktree add "$worktree_path" "$feature" || return 1
        else
            echo "vibetree: creating worktree ~/.vibetrees/$repo_name/$worktree_name (new branch)"
            git -C "$repo_root" worktree add -b "$feature" "$worktree_path" || return 1
        fi
    fi

    _sbx_run_kit "$harness" "$DOTFILES_PATH/llm/$harness/" "$worktree_path" "$harness-$repo_name-$worktree_name"
}


# Vibe tree: pick an existing sandbox or create a new feature worktree
# Usage: vibetree [--harness <name>] [feature]
#   vibetree                           → interactive menu (vibe)
#   vibetree --harness pi              → interactive menu (pi)
#   vibetree "my feature"              → new worktree (vibe)
#   vibetree --harness pi "my feature" → new worktree (pi)
function vibetree() {
    local harness="vibe"
    local feature=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --harness)
                [ $# -ge 2 ] || { echo "vibetree: --harness requires a value"; return 1; }
                harness="$2"
                shift 2
                ;;
            --harness=*)
                harness="${1#--harness=}"
                shift
                ;;
            -*)
                echo "vibetree: unknown option '$1'"
                return 1
                ;;
            *)
                [ -z "$feature" ] || { echo "vibetree: unexpected argument '$1'"; return 1; }
                feature="$1"
                shift
                ;;
        esac
    done

    local repo_root repo_name
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "vibetree: not in a git repository"; return 1; }
    repo_name=$(basename "$repo_root")

    if [ -n "$feature" ]; then
        _vibetree_new "$harness" "$feature"
        return
    fi

    if ! command -v fzf >/dev/null; then
        echo "vibetree: fzf is required"
        return 1
    fi

    local existing choice
    existing=$(_vibetree_list "$harness" "$repo_name")

    if [ -n "$existing" ]; then
        choice=$(printf '%s\n+ new feature\n' "$existing" \
            | fzf --prompt="$harness > " --height=10 --reverse)
        [ -z "$choice" ] && return 0
    else
        echo "vibetree: no existing features for '$harness'"
        choice="+ new feature"
    fi

    if [ "$choice" = "+ new feature" ]; then
        local new_feature
        read -r -p "Feature: " new_feature
        [ -z "$new_feature" ] && return 0
        _vibetree_new "$harness" "$new_feature"
    else
        echo "vibetree: attaching to ${harness}-${repo_name}-${choice}"
        sbx run --name "${harness}-${repo_name}-${choice}"
    fi
}
