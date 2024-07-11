{...}: {
  programs.vim = {
    enable = true;
    extraConfig = ''
            " Define a function and keybind to run shellcheck in a new buffer
            function! RunShellCheck()
            write

            let l:output = system('shellcheck ' . expand('%'))

            if empty(l:output)
              echo "ShellCheck: OK"
            else
            rightbelow vsplit
            enew
            setlocal buftype=nofile
            setlocal bufhidden=hide
            setlocal noswapfile
            setlocal filetype=sh
            file ShellCheck

            call append(0, split(l:output, "\n"))
              endif
            endfunction

            nnoremap <leader>sc :call RunShellCheck()<CR>
            " End ShellCheck setup

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
