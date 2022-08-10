#!/bin/zsh

if [ -d $1/.git ]; then
	url=$(cd $1; git config --get remote.origin.url)
	git submodule add $url $1
	git submodule absorbgitdirs $1
	git config submodule.$1.ignore dirty
fi
