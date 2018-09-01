scriptencoding utf-8

" This is a copy of the dark.vim theme, however it does not change colors in
" the different modes, so should bring some performance improvements because
" airline does not have to redefine highlighting groups after they have been
" setup once.

" Each theme is contained in its own file and declares variables scoped to the
" file.  These variables represent the possible "modes" that airline can
" detect.  The mode is the return value of mode(), which gets converted to a
" readable string.  The following is a list currently supported modes: normal,
" insert, replace, visual, and inactive.
"
" Each mode can also have overrides.  These are small changes to the mode that
" don't require a completely different look.  "modified" and "paste" are two
" such supported overrides.  These are simply suffixed to the major mode,
" separated by an underscore.  For example, "normal_modified" would be normal
" mode where the current buffer is modified.
"
" The theming algorithm is a 2-pass system where the mode will draw over all
" parts of the statusline, and then the override is applied after.  This means
" it is possible to specify a subset of the theme in overrides, as it will
" simply overwrite the previous colors.  If you want simultaneous overrides,
" then they will need to change different parts of the statusline so they do
" not conflict with each other.
"
" First, let's define an empty dictionary and assign it to the "palette"
" variable. The # is a separator that maps with the directory structure. If
" you get this wrong, Vim will complain loudly.
let g:airline#themes#matts_dark_minimal#palette = {}

let s:guifg = '#b2b2b2'
let s:guibg = '#303030'
let s:ctermfg = 252
let s:ctermbg = 236

" First let's define some arrays. The s: is just a VimL thing for scoping the
" variables to the current script. Without this, these variables would be
" declared globally. Now let's declare some colors for normal mode and add it
" to the dictionary.  The array is in the format:
" [ guifg, guibg, ctermfg, ctermbg, opts ]. See "help attr-list" for valid
" values for the "opt" value.
let s:N1 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:N2 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:N3 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:N4 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:N5 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:N6 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let g:airline#themes#matts_dark_minimal#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3, s:N4, s:N5, s:N6)
let g:airline#themes#matts_dark_minimal#palette.inactive = airline#themes#generate_color_map(s:N1, s:N2, s:N3, s:N4, s:N5, s:N6)

let s:I1 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:I2 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:I3 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:I4 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:I5 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:I6 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let g:airline#themes#matts_dark_minimal#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3, s:I4, s:I5, s:I6)
let g:airline#themes#matts_dark_minimal#palette.replace = airline#themes#generate_color_map(s:I1, s:I2, s:I3, s:I4, s:I5, s:I6)

let s:V1 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:V2 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:V3 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:V4 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:V5 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let s:V6 = [ s:guifg , s:guibg , s:ctermfg , s:ctermbg ]
let g:airline#themes#matts_dark_minimal#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3, s:V4, s:V5, s:V6)

" Accents are used to give parts within a section a slightly different look or
" color. Here we are defining a "red" accent, which is used by the 'readonly'
" part by default. Only the foreground colors are specified, so the background
" colors are automatically extracted from the underlying section colors. What
" this means is that regardless of which section the part is defined in, it
" will be red instead of the section's foreground color. You can also have
" multiple parts with accents within a section.
let g:airline#themes#matts_dark_minimal#palette.accents = {
      \ 'red': [ '#d70000' , '' , 160 , ''  ]
      \ }

" let pal = g:airline#themes#matts_dark_minimal#palette
" for item in ['replace', 'visual', 'inactive']
"   " why doesn't this work?
"   " get E713: cannot use empty key for dictionary
"   "let pal.{item} = pal.normal
"   exe "let pal.".item." = pal.normal"
"   for suffix in ['_modified', '_paste']
"     exe "let pal.".item.suffix." = pal.normal"
"   endfor
