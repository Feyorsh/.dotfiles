# go is managed by path_helper
export PATH="$PATH:/opt/homebrew/bin/:/Users/george/.cargo/bin:$(go env GOPATH)/bin:/Users/george/.gem/ruby/2.6.0/bin:/usr/local/bin:/usr/bin"

[ -f "/Users/george/.ghcup/env" ] && source "/Users/george/.ghcup/env" # ghcup-env

function better_man() {
	_V=0;

	while getopts "v" OPTION
	do
		case $OPTION in
		v) _V=1
		;;
		esac
	done

	for arg in $@
	do
		if [[ $arg == '-v' ]]; then
			continue
		fi

		checksums=();
		pages="";
		man -wa $arg |
		{
			while read line
			do
				checksum="`cksum $line | cut -d ' ' -f 1`";
				if [[ ${checksums[*]} =~ (^|[[:space:]])$checksum($|[[:space:]]) ]]; then
					[ $_V -eq 1 ] && >&2 echo "Man page $line is a duplicate, skipping...";
				else
					checksums+=($checksum);
					pages+="$line ";
				fi
			done # fuck this stupid goddamn language (pipe creates copy of pages)
			LESSOPEN='|man %s' less -is `echo $pages | tr '\n' ' '`;
		}
	done
}
alias bman='better_man'
alias diff='git diff'
alias ls='echo "WRONG LS!\n"; ls'
alias 128_compile='clang++ -std=c++20 -g -O0 -Wall -Wextra -Werror -pedantic'
setopt interactivecomments

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(starship init zsh)"

