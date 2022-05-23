

" Set syntax highlighting for specific file types
autocmd BufRead,BufNewFile Appraisals set filetype=java
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd Syntax javascript set syntax=jquery


" Color scheme
colorscheme molokai
highlight NonText guibg=#060606
highlight Folded  guibg=#0A0A0A guifg=#9090D0


" monokai原始背景色
let g:molokai_original = 1
" let g:rehash256 = 1

set background=light

" set comment color
" Xterm256 color names for console Vim: https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
hi Comment ctermfg=31 guifg=#0087af 



