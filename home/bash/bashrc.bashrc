# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# No path shown
#export PS1='\e[1;32m[$(date +"%H:%M")] \e[1;34m${PWD/*\//}\e[m$ \e[m'

# For a terminal fuzzy searcher
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export FZF_DEFAULT_COMMAND="fdfind --type d . $HOME"

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

# Get current git branch in PS1
source ~/.git-prompt.sh

# Make PS1 less gigantic
export PS1='\[\033[01;34m\]$(__git_ps1 "(%.32s)") \[\033[01;32m\]\W\[\033[0m\] \$ '

# === HARFANGLAB ===

# Seting up pip so it looks for internal packages
export PIP_INDEX_URL="https://nexus.huruk.ai/repository/hurukai/simple"

# Alias the datastore command line interface to warehouse-cli
alias warehouse-cli='~/Work/static/datastore/datastore-django-cli/datastore/bin/datastore-django-cli'

# Alias to get info on hash
alias checkhash='~/Work/static/datastore/datastore-django-cli/datastore/bin/datastore-django-cli samples info'

# Alias to get the actual hash from metabase
alias metahash='~/Work/mytools/metahash/metahash'

# Alias to download a binary from the datastore
alias gethash='~/Work/static/datastore/datastore-django-cli/datastore/bin/datastore-django-cli samples get'

# Alias to find files easily
alias findfile='find | grep'

# 'Alias' (in reality a function so it accepts params) to zip a malware
zipmal () {
    zip --password "infected" $1.zip $1
    echo "successfuly compressed malware with password 'infected'."
}

unzipmal () {
    ZIP=$1
    unzip -P "infected" $ZIP
    chmod -R 0444 ${ZIP::-4}
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export BACKEND_API_ENCRYPTION_KEY='Jri11tYc9uir3KXJABCVn2jG-r2IPJXPY4UexrnQbEw='

# Pdb
alias pdb='python3 -m pdb -c continue'

# Memory
mem () {
    sudo du -hs $(ls -A $1) | sort -rh
}

# Langsmith port forwarding
alias langsmith='ssh -N -L 1984:127.0.0.1:1984 merlin'

alias bssh='${USER}@carol -p 222 -t -- --user hlab'

alias ssh-merlin='ssh -Y merlin'
alias ssh-lancelot='ssh -Y lancelot'
alias ssh-diablo='ssh "goncalo:diablo@warpgate.prod.huruk.ai" -p 2223 -t "export TERM=kitty; bash"'
alias corneille-prod="ssh 'goncalo:corneille-prod-1@warpgate.prod.huruk.ai' -p 2223 -t 'k9s --kubeconfig /etc/rancher/k3s/k3s.yaml'"
alias corneille-prod-ssh="ssh 'goncalo:corneille-prod-1@warpgate.prod.huruk.ai' -p 2223"

alias merlin-gpus='ssh merlin -t "nvidia-smi -l 1"'

export PATH=$PATH:$HOME/minio-binaries/

# === Build virtualenv ===
build () {
    make clean && make install-develop$1 && source .venv/bin/activate
}

# Enable autocomplete for the build function
complete -F _build_completion build

# Autocomplete function for build
_build_completion() {
    local cur_word args
    COMPREPLY=()
    cur_word="${COMP_WORDS[COMP_CWORD]}"
    args=($(compgen -W "$(make -qp | awk -F: '/^[a-zA-Z0-9][^\$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A) print A[i]}' | grep 'install-develop-' | sed 's/install-develop//g' | tr '\n' ' ')" -- "$cur_word"))
    COMPREPLY=("${args[@]}")
    return 0
}
# ===                  ===

# Alias for docker compose
alias doc='docker compose'
alias docd='docker compose -f docker-compose.dev.yml'

# Alias for port forwarding
alias port-forward="python /home/goncalo/Work/utils/port-forward.py"

# add `~/bin` to the paths that your shell searches for executables
export PATH="$PATH:$HOME/bin"
. "$HOME/.cargo/env"

alias fetch='git fetch origin *:*'

# For neovim avante
export OPENAI_API_KEY="sk-1853c7c498ed4618a70d68b98eb36bdb"

# Alias for k9s
alias k="k9s"
alias d4y="kubectl --context d4y-pinniped"
alias corneille="kubectl --context d4y-pinniped -n corneille-328-develop"

green() { echo -e "\033[1;32m$1\033[0m"; }
red()   { echo -e "\033[1;31m$1\033[0m"; }
yellow(){ echo -e "\033[1;33m$1\033[0m"; }
blue()  { echo -e "\033[1;34m$1\033[0m"; }

# Automaticaly resolve conflicts in poetry.lock files
function reslocks() {
    if [ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ]; then
        red "No rebase in progress. Exiting."
        return 0
    fi

    blue "Starting automated rebase conflict resolver for poetry.lock..."

    while true; do
        if [ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ]; then
            green "Rebase complete."
            break
        fi

        blue "Resolving poetry.lock files..."
        find . -type f -name 'poetry.lock' -exec git checkout --theirs {} \; -exec git add {} \;

        conflicted=$(git diff --name-only --diff-filter=U)
        if [[ -n "$conflicted" ]]; then
            yellow "Conflicts still remain in the following files:"
            echo "$conflicted"
            red "Manual resolution required. Exiting."
            return 1
        fi

        green "All conflicts resolved. Continuing rebase step..."
        git rebase --continue
    done
}
export -f reslocks

# pnpm
export PNPM_HOME="/home/goncalo/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Cia k9s connection
alias cia='ssh lancelot -t "k9s --kubeconfig /etc/rancher/k3s/k3s.yaml"'

# D4y connection
alias d4y='k9s --context d4y-pinniped'

alias url='/home/goncalo/Work/static/url/.venv/bin/python -i /home/goncalo/Work/static/url/url.py'

alias testenv='set -o allexport; source local_test.env; set +o allexport'
