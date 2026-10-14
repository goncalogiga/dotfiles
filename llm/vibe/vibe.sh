# Vibe sandbox
# sbx run $KIT --name $(basename "$1") vibe "$1"
function vibe() {
	local arg=${1:-$PWD}
    local vibe_kit_path="$DOTFILES_PATH/llm/vibe/"

	if [ -d "$arg" ]; then
		local dir=$(realpath $arg)
		local name="$(basename $dir)"

		echo "Running 'sbx run "$vibe_kit_path" --name "$name" vibe "$dir" || sbx run --name "$name"'"
		sbx run "$vibe_kit_path" --name "$name" vibe "$dir" || sbx run --name "$name"
	else
		echo "$arg is not a directory."
	fi
}
