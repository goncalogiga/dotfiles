# Prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b) '

setopt PROMPT_SUBST
PROMPT='%F{blue}${vcs_info_msg_0_}%F{green}%1~%f $ '

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias n='nvim'

# Python
alias cvenv="uv venv"
alias svenv="source .venv/bin/activate"
alias dvenv="rm -rf .venv/"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="fd --type d . $HOME"

# cdf
alias cdf='cd $(fd --type d | fzf --height=45%)'

. "$HOME/.local/bin/env"
