" Maintainer:    Henrique C. Alves (hcarvalhoalves@gmail.com)
" Version:      1.0
" Last Change:    September 25 2008

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "matts-darkside"

" Vim >= 7.0 specific colors
if version >= 700
  hi CursorLine     ctermbg=232 term=none cterm=none
  hi CursorColumn   ctermbg=232
  hi MatchParen     ctermfg=250 ctermbg=232 cterm=bold
  hi Pmenu          ctermfg=255 ctermbg=238
  hi PmenuSel       ctermfg=0 ctermbg=148
endif

" General colors
hi Cursor           ctermbg=241
hi Normal           ctermfg=250 ctermbg=234
hi NonText          ctermfg=240 ctermbg=234
hi LineNr           ctermfg=240 ctermbg=234
hi StatusLine       ctermfg=253 ctermbg=232 cterm=italic
hi StatusLineNC     ctermfg=253 ctermbg=232
hi VertSplit        ctermfg=234 ctermbg=232
hi Folded           ctermbg=60 ctermfg=248
hi Title            ctermfg=253 cterm=bold
hi Visual           ctermfg=253 ctermbg=60
hi SpecialKey       ctermfg=244 ctermbg=236

" Syntax highlighting
hi Comment          ctermfg=244
hi Todo             ctermfg=226 ctermbg=233
hi Boolean          ctermfg=148
hi String           ctermfg=148
hi Identifier       ctermfg=148
hi Function         ctermfg=255
hi Type             ctermfg=103
hi Statement        ctermfg=103
hi Keyword          ctermfg=208
hi Constant         ctermfg=208
hi Number           ctermfg=208
hi Special          ctermfg=208
hi PreProc          ctermfg=230
" hi Todo

" Code-specific colors
hi pythonOperator   ctermfg=103

" For NERDTree, probably needs refining
hi Directory        ctermfg=148
" hi Title          ctermfg=103
" hi Special        ctermfg=103
" hi Identifier     ctermfg=148

hi djangoTagBlock   ctermfg=148
hi djangoFilter     ctermfg=229
hi djangoStatement  ctermfg=208
hi djangoVarBlock   ctermfg=148

" 144 148 103 229 208

hi WildMenu         ctermfg=233  ctermbg=148

