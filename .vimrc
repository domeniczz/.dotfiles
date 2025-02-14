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
set whichwrap+=<,>,[,]
set scrolloff=10
set laststatus=2
set ttimeoutlen=20
set timeoutlen=400
set path+=**
set wildmenu

if has('clipboard')
  set clipboard=unnamedplus
endif

set undodir=$HOME/.vim/undodir
set undofile

" set statusline=%f\ %m%=%l:%c\ %P

nnoremap Q <nop>

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

function! KillBufferOrCloseWindow()
  " Exit if in command window (access with q: or Q)
  if getcmdwintype() != ''
    quit
    return
  endif
  let l:curwin = winnr()
  let l:curbuf = bufnr('%')
  " Handle multiple windows showing current buffer
  if len(win_findbuf(l:curbuf)) > 1
    close
    return
  endif
  " Check if there are other valid buffers
  let l:has_valid_buffer = 0
  for buf in getbufinfo()
    if buf.listed && buf.bufnr != l:curbuf && buflisted(buf.bufnr)
      let l:has_valid_buffer = 1
      break
    endif
  endfor
  let l:should_quit = !l:has_valid_buffer
  let l:ft = &filetype
  if l:ft ==# "fugitive" || l:ft ==# "netrw"
    bdelete
    return
  endif
  if &modified
    let l:choice = confirm("Buffer has unsaved changes. Save before closing?", "&Yes\n&No\n&Cancel", 1)
    if l:choice == 1
      let l:filename = ""
      if empty(bufname("%"))
        let l:filename = input("Enter file name to save: ")
        if empty(l:filename)
          return
        endif
      endif
      try
        execute 'silent! write ' . fnameescape(l:filename)
      catch
        echoerr "Failed to save buffer: " . v:exception
        return
      endtry
    elseif l:choice == 2
      bdelete!
    else
      return
    endif
  else
    bdelete
  endif
  if l:should_quit
    quit
  endif
endfunction

nnoremap <silent> Q :call KillBufferOrCloseWindow()<CR>

function! Clearregs() abort
  let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
  for r in regs
    call setreg(r, @_)
  endfor
endfunction

" Optionally, map a key to call this function
" nnoremap <leader>cr :call Clearregs()<CR>
