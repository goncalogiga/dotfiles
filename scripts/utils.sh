# Shared helpers, sourced by the setup scripts

# Ask before downloading and running a remote install script.
#
# The script is saved to a temp file first, so nothing runs half-downloaded.
# Returns 1 if the user declines (or there is no terminal to ask on).
curl_sh() {
    local url="$1"
    shift

    local answer=""
    read -r -p "Download and run $url (sh $*)? [y/N] " answer </dev/tty || answer=""
    case "$answer" in
        [yY] | [yY][eE][sS]) ;;
        *)
            echo "Skipped $url" >&2
            return 1
            ;;
    esac

    local tmp status=0
    tmp="$(mktemp)"
    curl --proto '=https' --tlsv1.2 -fsSL "$url" -o "$tmp" || status=$?
    if [ "$status" -eq 0 ]; then
        sh "$tmp" "$@" || status=$?
    fi
    rm -f "$tmp"
    return "$status"
}
