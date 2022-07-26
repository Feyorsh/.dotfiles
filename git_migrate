#!/bin/zsh
url=$(cd $1; git config --get remote.origin.url)
git submodule add $url $1
git submodule absorbgitdirs $1
