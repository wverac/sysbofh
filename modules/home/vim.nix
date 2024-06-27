{...}: {
  programs.vim = {
    enable = true;
    extraConfig = ''
      "set number
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set ruler
      set showmatch
      set showmode
      set esckeys
      set nocompatible
      set backspace=indent,eol,start
      set nomodeline
      set hlsearch
      set mouse-=a
      set pastetoggle=<F2>
      nnoremap <leader>a :%!alejandra -qq<CR>
    '';
  };
  home.sessionVariables = {
    EDITOR = "vim";
  };
}
