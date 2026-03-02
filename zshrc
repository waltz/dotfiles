autoload -U colors && colors
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

# ============================================================================
# Async Git Status
# Fetches vcs_info in a background process to avoid blocking the prompt.
# Uses zsh's file descriptor mechanism to read results asynchronously.
# ============================================================================
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr " %F{121}●"
zstyle ':vcs_info:git:*' unstagedstr " %F{198}●"
zstyle ':vcs_info:git:*' formats "%F{215}[%b]%c%u%f"

typeset -g _vcs_info_cache=""
typeset -g _vcs_async_fd=""

function _vcs_async_worker() {
  cd -q "$1"
  vcs_info
  print -r -- "${vcs_info_msg_0_}"
}

function _vcs_async_callback() {
  local fd=$1
  {
    read -r -u $fd _vcs_info_cache
    zle && zle reset-prompt
  } always {
    exec {fd}<&-
    _vcs_async_fd=""
  }
}

function _vcs_async_start() {
  [[ -n "$_vcs_async_fd" ]] && exec {_vcs_async_fd}<&-
  exec {_vcs_async_fd}< <(_vcs_async_worker "$PWD")
  zle -F $_vcs_async_fd _vcs_async_callback
}

add-zsh-hook precmd _vcs_async_start
add-zsh-hook chpwd _vcs_async_start

setopt prompt_subst
PROMPT='%B%F{205}%2~ ${_vcs_info_cache:+$_vcs_info_cache }%F{white}%# %f%b'

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

# Add some Pipenv tools to the path.
export PATH="/Users/waltz/Library/Python/3.9/bin:$PATH"

# locate homebrew sbin
export PATH="/usr/local/sbin:$PATH"

# make sure homebrew is in the path
export PATH="/opt/homebrew/bin:$PATH"

# Load up mise (asdf replacement)
eval "$(mise activate zsh)"

# Mise autocomplete
# Regenerate this by running `mise completion zsh > ~/.local/share/mise/completions.zsh`
source ~/.local/share/mise/completions.zsh

export FZF_DEFAULT_COMMAND='rg --files --hidden'

# Disable fork safety so that Rails Spring boot works.
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY="YES"

# If there's a current bin dir in my home, then search it for
# stuff to run.
export PATH="$HOME/bin:$PATH"

alias resetmouse='printf '"'"'\e[?1000l'"'"

# Actually add the go path to the path.
export PATH="$GOPATH:$PATH"

# Git aliases
alias gst="git status"
alias gci="git commit"

# Load local overrides
source ~/.zshrc_local

# Report current directory to terminal via OSC 7 (enables Ghostty/iTerm2/etc to open new tabs in same directory)
precmd() {
  print -Pn "\e]7;file://${HOST}${PWD}\e\\"
}
