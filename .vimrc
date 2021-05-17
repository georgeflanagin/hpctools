filetype on


autocmd BufRead,BufNewFile *.json set syntax=ijkl
autocmd BufRead,BufNewFile *.ijkl set syntax=ijkl
autocmd BufRead,BufNewFile *.md   set syntax=markdown
autocmd BufRead,BufNewFile *.slurm   set syntax=slurm

set number
syntax on
set scrolloff=25

set ruler
set statusline=
set laststatus=2
set rulerformat=Line:%l,\ Col:%c%=%P
if has("statusline") 
    set statusline=%<%f\ %h%m%r%=%k[U+%04B]\ %-12.(Line:%l,Col:%c%)\ %P 
endif 

set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab 
map , !}fmt
map ! O"on_error":"test_empty",<Esc>
map @ O"on_error":"notify",<Esc>

" map + :%!xxd
" map = :%!xxd -r

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

colorscheme distinguished

augroup json_ft
  au!
  autocmd BufNewFile,BufRead *.json   set syntax=json
augroup END

augroup ijkl_ft
  au!
  autocmd BufNewFile,BufRead *.ijkl   set syntax=ijkl
augroup END


augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END

nnoremap + :Hexmode<CR>

command -bar Hexmode call ToggleHex()

function ToggleHex()
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    let b:oldft=&ft
    let b:oldbin=&bin
    setlocal binary
    silent :e 
    let &ft="xxd"
    let b:editHex=1
    %!xxd -g1
  else
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    let b:editHex=0
    %!xxd -r
  endif
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction
