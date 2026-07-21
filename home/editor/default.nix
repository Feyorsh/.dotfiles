{ pkgs, config, ... }:
{
  imports = [
    ./emacs
    ./spell.nix
    ./documentation.nix
  ];

  programs.vim = {
    enable = true;
    packageConfigurable = pkgs.vim-darwin;
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
