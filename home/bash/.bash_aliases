# Fuzzy search with cd
alias cdf='cd $(fzf --height=45%)'

# Make mv print what it does
alias mv='mv -v'

# Define a n for python neovim dev
function n() {
    source .venv/bin/activate 2> /dev/null && nvim.appimage $@ || nvim.appimage $@ 
}
export -f n

# Use nvim.appimage with nvim
alias nvim='nvim.appimage'

# Add cargo to path (Rust package manager)
export PATH="$HOME/.cargo/bin:$PATH"

# Source .venv
alias svenv="source .venv/bin/activate"

# Delete .venv
alias dvenv="rm -r .venv/"

function cvenv() {
    if [ $# -eq 0 ]; then
        python3.12 -m venv .venv
    else
        eval "python$1 -m venv .venv"
    fi

    .venv/bin/pip install isort black pdbpp poetry ipython
    . .venv/bin/activate
}
export -f cvenv

# Alias for ipython
alias p='ipython'