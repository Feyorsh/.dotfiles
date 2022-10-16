#!/bin/zsh

if [ -d $1/.git ]; then
	cd $1
	url=$(git config --get remote.origin.url)
	branch=$(git branch --show-current)
	cd - >/dev/null
	git submodule add -b branch $url $1
	git submodule absorbgitdirs $1
	git config submodule.$1.ignore all
fi
