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
