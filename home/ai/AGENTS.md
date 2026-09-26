### System information
You are running on a macOS system using Nix as a package manager and nix-darwin/home-manager as the system configurator.
Consequently, things are different from a traditional macOS install.
In particular, you should value reproducability and you should never modify files outside the user's home directory without explicit permission.

### Where things are
- Most projects are in ~/Personal/oss
- Dotfiles are at ~/.dotfiles and Emacs config is at ~/.dotfiles/home/config/editor/emacs/config.org
- Emacs packages are not downloaded in ~/.emacs.d, but rather in /nix/store. If you need to find an Emacs package, prefer using something like `emacsclient -e '(find-library-name (or (cdr (find-function-library SYMBOL)) (symbol-file SYMBOL 'defvar)))'` or a _very_ targeted `fd` search through the Nix store

### Profiling
It is ok to hypothesize about what approaches may or may not be faster, but you should ultimately test your hypotheses with the relevant benchmarking tools to see if a proposed solution is actually faster.

### Preferred CLI tools
This machine has modern alternatives to traditional Unix tools installed, ALWAYS prefer using them over the traditional ones unless there's a strong reason not to.

#### Search Tools
- **ripgrep (`rg`)** instead of `grep`:
  - Faster recursive search with smart defaults
  - Respects `.gitignore` by default
  - Example: `rg "pattern"` instead of `grep -r "pattern"`

- **fd** instead of `find`:
  - Faster file search with intuitive syntax
  - Respects `.gitignore` by default
  - Example: `fd "filename"` instead of `find . -name "filename"`

### Available tools
Although you are on macOS, most utilities installed are actually from GNU coreutils or inetutils, not the pre-installed BSD tools.
You will almost never need to use a tool in /bin or /usr/bin; do not go looking for binaries there.
If a binary you need is not in `$PATH`, try spinning up a Nix shell: `nix shell nixpkgs#PACKAGE`.

**Search & selection**:
- `rg` (ripgrep) - fast grep
- `fd` - fast find

**System**:
- `hyperfine` - benchmarking

**Programming languages**:
- `uv` - A fast Python package and project manager, _always_ prefer over Poetry
- `ruff` - A fast Python linter and formatter, use this to format any nontrivial Python code that you write
