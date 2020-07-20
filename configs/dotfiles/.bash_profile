#!/usr/bin/env bash

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.macstrap/configs/dotfiles/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
	source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# Clean out duplicates from shell history
export HISTCONTROL=ignoreboth:erasedups

# git completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_COMMAND='fd --type f'

# alias to search in gitignored files
fzfall () {
    bash -c "FZF_DEFAULT_COMMAND=\"${FZF_DEFAULT_COMMAND} --no-ignore-vcs\"; fzf $@" -- "$@"
}
alias fzfa='fzfall'

# upgrade outdated brew installations
alias brewUpgrade="brew update && brew outdated -v | fzf -m | awk '{print \$1}' | xargs brew upgrade"

# checkout a branch 
alias checkout="git branch -l | fzf | xargs git co"

# remove duplicates from bash history
alias pruneHistory="tac $HISTFILE | awk '!x[$0]++' | tac | sponge $HISTFILE"

eval "$(starship init bash)"

export PATH="$HOME/.cargo/bin:$PATH"
