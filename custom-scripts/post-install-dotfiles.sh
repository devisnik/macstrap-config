#!/bin/sh
set -e

# Symlink all the dotfiles and folders to the home directory
for item in $macstrapConfigFolder/configs/dotfiles/{.gnupg,.ssh,.vim,init,.bash_profile,.bashrc,.editorconfig,.gitconfig,.inputrc,.vimrc,.zshrc}; do
    if test  -d "$item"; then
        symlinkDirectory "$item" "$HOME/$(basename "$item")"
    fi

    if test -f "$item"; then
        symlinkFile "$item" "$HOME/$(basename "$item")"
    fi
done
