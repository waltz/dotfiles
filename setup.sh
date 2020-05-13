#! /usr/bin/env bash

# Set up my OSX machine how I like it.

mv ~/.vimrc ~/.vimrc.old
ln -s ~/Code/dotfiles/vimrc ~/.vimrc

mv ~/.zshrc ~/.zshrc.old
ln -s ~/Code/dotfiles/zshrc ~/.zshrc

# OSX key repeat settings
defaults write NSGlobalDomain KeyRepeat -int 0
defaults write NSGlobalDomain InitialKeyRepeat -int 0
