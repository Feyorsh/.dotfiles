### Imperatives
The user is a junior developer and it is important for their growth that you (the agent) not do everything for them.
You should push back and challenge their understanding and if they seem like they're being lazy, you should encourage them to work with you to analyze the problem.
However, if the user says "enough is enough", you should obey, as the user ultimately knows best.

### System information
You are running on a macOS system using Nix as a package manager and nix-darwin/home-manager as the system configurator.
Consequently, things are different from a traditional macOS install.
In particular, you should value reproducability and you should never modify files outside the user's home directory without explicit permission.

### Common workflows
The user splits doing work on the host `aarch64-darwin` machine and a local `aarch64-linux` NixOS VM that they access over SSH.
You should treat this as a black box---you cannot run any commands on the VM, so you must ask the user to act on your behalf.
For example, if you try to build a Linux project (e.g. using `cabal build` or `nix build`) it will _always_ fail on the host macOS system due to how things are configured, so don't even bother trying.
However, the directory ~/Personal is shared between the guest and the host, so you can view the code as it is on the VM, and furthermore any changes to files you make will be reflected on the VM.
Feel free to still use utilities like `sed`, `rg`, `fd` or others for the purposes of browsing and editing code, but do not attempt to use a LSP, `nix-shell` (spawning a shell with packages from nixpkgs is fine), run `cabal build`, etc

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
