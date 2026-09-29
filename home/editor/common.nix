{ pkgs, ... }:

{
  imports = [
    ./spell.nix
  ];

  home.packages = with pkgs; [
    emacs-lsp-booster
    rassumfrassum

    # lsps
    clang-tools
    sourcekit-lsp
    shellcheck
    gopls
    rust-analyzer
    nixd
    ruff ty basedpyright
    matlab-language-server
    zls
    dhall-lsp-server
    tinymist
    # verible
    # do not bother installing HLS, but do install tools and formatters
    haskellPackages.hoogle haskellPackages.fourmolu haskellPackages.cabal-fmt
  ];

  programs.vim = {
    enable = true;
    packageConfigurable = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.vim-darwin else pkgs.vim-full;
    extraConfig = ''
      if $INSIDE_EMACS == "vterm"
        silent! !vterm_printf "51;Eevil-emacs-state"
        autocmd VimLeave * :!vterm_printf "51;Eevil-insert-state"
      endif

      set number
      set relativenumber
      syntax enable
    '';
  };
}
