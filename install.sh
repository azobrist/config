#!/bin/bash
TAG=installed
if [ -f "$TAG" ]
then
	echo "re-initing and exiting"
	exec bash
	exit 1
fi

#check if zsh is used
if [ -f ~/.zshrc ]
then
	echo "ZSH_THEME=powerlevel10k/powerlevel10k" >> ~/.zshrc
	echo "source $HOME/.bash_aliases" >> ~/.zshrc
	echo "source $HOME/.zsh_plugins" >> ~/.zshrc
fi

# backup and link
bal () {
	repo=$(pwd)
	mkdir -p $repo/original
	if [ -f ~/$1 ]; then
		mv ~/$1 $repo/original/$1
	fi
	ln -s $repo/$1 ~/$1
}

bal .bash_aliases
bal .gitconfig
bal .vimrc
bal .zsh_plugins

touch $TAG
exec bash
