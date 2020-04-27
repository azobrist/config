#/usr/bin/env bash
LIST=~/.netdevlist
if [ -d $LIST ]; then
	complete -W "$(ls $LIST)" connect getfrom sendto
fi
