setopt prompt_subst

autoload -U colors && colors
autoload -Uz compinit && compinit
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr " %F{orange}●"
zstyle ':vcs_info:git:*' unstagedstr " %F{limegreen}●"
zstyle ':vcs_info:git:*' formats "%F{yellow}[%b]%u%c "

function update_vcs_info() {
    vcs_info
}

add-zsh-hook precmd update_vcs_info
add-zsh-hook chpwd update_vcs_info

PROMPT='%F{magenta}%2~ ${vcs_info_msg_0_}%F{white}#%  %f'

export LSCOLORS="ExGxFxdaCxDaDahbadacec"

# Don't share command history across shell instances.
unsetopt share_history

# Ignore duplicate commands in the history.
setopt HIST_IGNORE_DUPS

# LS aliases
alias ls="ls --color"
alias ll="ls -al"

# Git shortcuts
alias gst="git status"
alias gci="git commit"

# Use neovim
alias vim="nvim"
export EDITOR="nvim"

. "$HOME/.asdf/asdf.sh"

# Add some Pipenv tools to the path.
export PATH="/Users/waltz/Library/Python/3.9/bin:$PATH"

# locate homebrew sbin
export PATH="/usr/local/sbin:$PATH"

export FZF_DEFAULT_COMMAND='rg --files --hidden'

# Disable fork safety so that Rails Spring boot works.
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY="YES"

# If there's a current bin dir in my home, then search it for
# stuff to run.
export PATH="$HOME/bin:$PATH"

. ~/.asdf/plugins/java/set-java-home.zsh

alias resetmouse='printf '"'"'\e[?1000l'"'"

# Load local overrides
source ~/.zshrc_local
