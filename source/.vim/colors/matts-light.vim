set background=light
highlight clear

if exists("syntax_on")
    syntax reset
endif

let colors_name = "matts-light"

" Vim >= 7.0 specific colors
if version >= 700
    " hi CursorLine cterm=none
    " hi CursorColu ctermbg=255
    " hi MatchParen ctermbg=254
    " hi Pmenu      guifg=#ffffff guibg=#444444 ctermfg=255 ctermbg=238
    " hi PmenuSel   guifg=#000000 guibg=#b1d631 ctermfg=0 ctermbg=148
endif


" Chrome colors
hi Normal       ctermfg=236
hi NonText      ctermfg=189
hi LineNr       ctermfg=189
hi VertSplit    ctermfg=231 ctermbg=236
hi ColorColumn              ctermbg=255
hi LongLine                 ctermbg=255
hi TabLine      ctermfg=254 ctermbg=236
hi TabLineFill  ctermfg=254 ctermbg=236
hi StatusLine   ctermfg=236 ctermbg=252
hi StatusLineNC ctermfg=236 ctermbg=252
hi Visual                   ctermbg=189
hi MatchParen               ctermbg=189
hi Search                   ctermbg=229
hi SpecialKey   ctermfg=249 ctermbg=229
hi WildMenu     ctermfg=236 ctermbg=148
hi PMenu                    ctermbg=252
hi PMenuSel     ctermfg=231 ctermbg=236

" Source colors
hi Boolean      ctermfg=69
hi Comment      ctermfg=249
hi Constant     ctermfg=19
hi Directory    ctermfg=103
hi Function     ctermfg=19
hi Identifier   ctermfg=103
hi Keyword      ctermfg=27
hi Label        ctermfg=28
hi Number       ctermfg=28
hi Operator     ctermfg=27
hi PreProc      ctermfg=91
hi Special      ctermfg=103
hi Statement    ctermfg=27
hi String       ctermfg=126
hi Todo         ctermfg=249 ctermbg=229
hi Type         ctermfg=28

" C-Specific
" hi cStructure   ctermfg=28
" hi cType        ctermfg=28

" Vim-Specific
" hi vimCommentTitle ctermfg=248

" Syntax highlighting
" hi Boolean      guifg=#b1d631 gui=none ctermfg=148
" hi Comment        guifg=#808080 gui=italic ctermfg=244
" hi Constant   guifg=#ff9800 gui=none  ctermfg=208
" hi Function   guifg=#ffffff gui=bold ctermfg=255
" hi Identifier     guifg=#b1d631 gui=none ctermfg=148
" hi Keyword        guifg=#ff9800 gui=none ctermfg=208
" hi Number     guifg=#ff9800 gui=none ctermfg=208
" hi PreProc        guifg=#faf4c6 gui=none ctermfg=230
" hi Special        guifg=#ff9800 gui=none ctermfg=208
" hi Statement  guifg=#7e8aa2 gui=none ctermfg=103
" hi String         guifg=#b1d631 gui=italic ctermfg=148
" hi Todo         guifg=#000000 guibg=#e6ea50 gui=italic
" hi Type       guifg=#7e8aa2 gui=none ctermfg=103

" Code-specific colors
" hi pythonOperator guifg=#7e8aa2 gui=none ctermfg=103

" For NERDTree, probably needs refining
" hi Directory    ctermfg=148
" hi Title        ctermfg=103
" hi Special      ctermfg=103
" hi Identifier   ctermfg=148

" hi djangoTagBlock   ctermfg=148
" hi djangoFilter     ctermfg=229
" hi djangoStatement  ctermfg=208
" hi djangoVarBlock   ctermfg=148

" 144 148 103 229 208

" hi WildMenu     ctermfg=236  ctermbg=148

