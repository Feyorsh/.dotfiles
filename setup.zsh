#!/bin/zsh

cd `dirname $0`
stow -v --target=.git .githooks
git submodule update --init --recursive


cd starship/starship; cargo build --release; ln -sf target/release/starship /usr/local/bin/starship
