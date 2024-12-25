syntax on
set number relativenumber
" set wildmenu
" set wildmode=longest:list,full
" set autoindent " Minimal automatic indenting for any filetype.
set backspace=indent,eol,start " Intuitive backspace behavior.
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set wrap

" allow left and right arrow keys to move across lines in Insert mode
set whichwrap+=<,>,[,]

if has('clipboard')
  set clipboard=unnamedplus
endif

set undodir=$HOME/.vim/undodir
set undofile

" https://github.com/jeffkreeftmeijer/vim-numbertoggle
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" Use a line cursor within insert mode and a block cursor everywhere else.
"
" Reference chart of values:
"   Ps = 0  -> blinking block.
"   Ps = 1  -> blinking block (default).
"   Ps = 2  -> steady block.
"   Ps = 3  -> blinking underline.
"   Ps = 4  -> steady underline.
"   Ps = 5  -> blinking bar (xterm).
"   Ps = 6  -> steady bar (xterm).
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Allow files to be saved as root when forgetting to start vim using sudo
command W :execute ':silent! write !sudo tee % > /dev/null' | :edit!

function! Clearregs() abort
  let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
  for r in regs
    call setreg(r, @_)
  endfor
endfunction

" Optionally, map a key to call this function
" nnoremap <leader>cr :call Clearregs()<CR>
