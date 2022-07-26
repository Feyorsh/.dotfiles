#!/bin/zsh

# consider changing .githooks from a flat directory (all hooks lumped together) to this:
# .githooks
#    |- nvim/vim-plug
#    |     |- post-merge
#    |- tmux/plugins/tmux-sensible
#          |- pre-commit
# this way it reflects the hook directory structure. Stow your hooks for your stow repo!
vimplug_hooks=$(cd `dirname $0`/nvim/vim-plug; git rev-parse --git-path hooks)
ln -sf $(cd `dirname $0`; pwd)/.githooks/post-merge_vim-plug $vimplug_hooks/post-merge
chmod +x $(cd `dirname $0`; pwd)/.githooks/post-merge_vim-plug
