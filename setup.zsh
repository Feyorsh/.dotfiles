#!/bin/zsh

cd `dirname $0`
git submodule update --init --recursive

stow -v --target=.git .githooks

cd starship/starship; cargo build --release; ln -sf target/release/starship /usr/local/bin/starship
