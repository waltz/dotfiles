#!/usr/bin/env bash
# Link a dotfiles tree into $HOME.
#
# Usage: install.sh [repo-root]
#
# Every file under <repo-root>/home is linked into $HOME, then every file under
# <repo-root>/<os> (darwin or linux). Overlay repos reuse this script by passing
# their own root. Real files that would be replaced are moved into
# ~/.dotfiles-backup/<timestamp>/ first.

set -euo pipefail

root=$(cd "${1:-$(dirname "$0")}" && pwd)
os=$(uname -s | tr '[:upper:]' '[:lower:]')
backup_dir=$HOME/.dotfiles-backup/$(date -u +%Y%m%dT%H%M%SZ)

link_tree() {
  local src=$1
  [[ -d $src ]] || return 0
  find "$src" -type f ! -name .DS_Store | while read -r file; do
    local rel=${file#"$src"/}
    local dst=$HOME/$rel
    if [[ -L $dst && $(readlink "$dst") == "$file" ]]; then
      continue
    fi
    mkdir -p "$(dirname "$dst")"
    if [[ -e $dst || -L $dst ]]; then
      mkdir -p "$(dirname "$backup_dir/$rel")"
      mv "$dst" "$backup_dir/$rel"
      echo "Backed up: ~/$rel"
    fi
    ln -s "$file" "$dst"
    echo "Linked: ~/$rel"
  done
}

link_tree "$root/home"
link_tree "$root/$os"

# The rest only applies to this repo, not to overlays.
[[ $root == "$(cd "$(dirname "$0")" && pwd)" ]] || exit 0

if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
  git clone -q https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

if [[ $os == darwin ]]; then
  # Key repeat
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  # Save screenshots to the Downloads folder
  defaults write com.apple.screencapture location ~/Downloads
fi
