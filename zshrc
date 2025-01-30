setopt prompt_subst

autoload -U colors && colors
autoload -Uz compinit && compinit
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr " %F{121}●"
zstyle ':vcs_info:git:*' unstagedstr " %F{198}●"
zstyle ':vcs_info:git:*' formats "%F{215}[%b]%c%u "

function update_vcs_info() {
    vcs_info
}

add-zsh-hook precmd update_vcs_info
add-zsh-hook chpwd update_vcs_info

PROMPT='%B%F{205}%2~ ${vcs_info_msg_0_}%F{white}%#  %f%b'

# Don't share command history across shell instances.
unsetopt share_history

# Ignore duplicate commands in the history.
setopt HIST_IGNORE_DUPS

# export LSCOLORS="GxFxCxDxBxegedabagaced"
export LSCOLORS="ExGxFxdaCxDaDahbadacec"

export CLICOLOR=1

# LS aliases
alias ls="ls --color"
alias ll="ls -al"

# Git shortcuts
alias gst="git status"
alias gci="git commit"

# Use neovim
alias vim="nvim"
export EDITOR="nvim"

# Load up asdf
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

alias resetmouse='printf '"'"'\e[?1000l'"'"

has_asdf_plugin() {
  asdf plugin list 2>/dev/null | grep -q "^$1\$"
  return $?
}

# Point $JAVA_HOME where asdf has it installed.
if has_asdf_plugin "java"; then
  . ~/.asdf/plugins/java/set-java-home.zsh
fi

# Set the current $GO_HOME, etc.
if has_asdf_plugin "golang"; then
  . ~/.asdf/plugins/golang/set-env.zsh
fi

# Explicitly support go modules
export ASDF_GOLANG_MOD_VERSION_ENABLED=true

# Actually add the go path to the path.
export PATH="$GOPATH:$PATH"

# Git aliases
alias gst="git status"
alias gci="git commit"

# Load local overrides
source ~/.zshrc_local
