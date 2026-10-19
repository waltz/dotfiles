# Dotfiles

Collection of configuration files for tools I use regularly.

## Install

```sh
git clone https://github.com/waltz/dotfiles ~/Code/dotfiles
~/Code/dotfiles/install.sh
```

`install.sh` links every file under `home/` into `~`, then every file under `darwin/` or `linux/` for the current OS. Files it would replace are moved to `~/.dotfiles-backup/<timestamp>/`. Re-run it after pulling.

Another repo can layer on top by calling `install.sh <its-root>` with the same layout.

## Machine-specific settings

These optional files are loaded if they exist:

* `~/.config/zsh/local.d/*.zsh` and `~/.zshrc_local`
* `~/.config/git/local`, which is where `user.email` belongs
* `~/.config/tmux/local.conf`
* `~/.config/nvim/local.lua`
