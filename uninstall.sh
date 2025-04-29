#!/bin/bash
TAG=installed
if [ ! -f "$TAG" ]
then
	exit 1
fi

revert () {
	if [ -f "original/$1" ]; then
		rm ~/$1
		mv original/$1 ~/$1
	fi
}

#continue
revert .bash_aliases
revert .gitconfig
rm -r original
rm $TAG
