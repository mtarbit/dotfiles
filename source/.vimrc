" Use pathogen for neater plugin management.
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Recognise file-type-specific plugin config in ftplugins dirs.
filetype plugin on

" Do file-type-specific auto-indenting.
" Needed for <leader>t formatting a file.
filetype indent on


" ------------------------------------------------------------------------------
" General Setup
" ------------------------------------------------------------------------------

" Don't hobble vim in favour of vi-compatibility.
set nocompatible

" Don't wrap lines.
set nowrap

" Number lines (using relative line-numbering if it's available).
" if exists('+relativenumber')
"     set relativenumber
" else
    set number
" endif

" Don't beep or flash as an alert.
set visualbell t_vb=

" Show options when tab-completing from the command line.
set wildmenu
" Show longest common sub-string on first tab, then cycle on subsequent tabs.
set wildmode=longest:full,full

" Enable mouse support in all modes.
set mouse=a

" Allow motions and back-spacing over line-endings etc.
set backspace=indent,eol,start
set whichwrap=h,l,b,<,>,~,[,]

" Don't do folding.
set nofoldenable

" Open new splits at bottom/right rather than top/left.
set splitbelow
set splitright

" Look for modeline settings on the first line of a file.
set modeline
set modelines=5

" Start scrolling slightly before the cursor reaches an edge.
set scrolloff=5
set sidescrolloff=10

" Scroll sideways a character at a time, rather than a screen at a time.
set sidescroll=1

" Delete comment character when joining commented lines.
set formatoptions+=j

" Keep temporary files out of working directories. Trailing double-slash tells
" vim to base the filename on the full path of the original to avoid conflicts.
set directory=~/.vim/tmp/swap//

" Use solid lines for folds and vertical splits.
set fillchars=fold:─,vert:│

" Configure the status line unless we're using the powerline plugin.
if !exists('g:Powerline_loaded') || !g:Powerline_loaded
    " Always show a status line above the command prompt.
    set laststatus=2
    set statusline=t\ %r%m%y\ %=[%l\ of\ %L]
endif

let g:airline_section_x = airline#section#create_right(['filetype', 'ffenc'])
let g:airline_section_y = airline#section#create_right(['%p%%'])
let g:airline_section_z = airline#section#create(['%l:%v'])
let g:airline_section_error = ''
let g:airline_section_warning = ''
let g:airline_theme = 'matts_dark_minimal'

" Auto-commands
augroup mt_general
    autocmd!

    " Change cursor color in insert mode where supported.
    " if &term =~ "xterm\\|rxvt"
    "     :silent !echo -ne "\033]12;red\007"
    "     let &t_SI = "\033]12;orange\007"
    "     let &t_EI = "\033]12;red\007"
    "     autocmd VimLeave * :!echo -ne "\033]12;red\007"
    " endif

    " Move to the directory of the current file automatically.
    " autocmd BufEnter * lcd %:p:h

    " Start in insert mode after opening a command window
    " (with Ctrl-F from cmdline or q:, q/, q? from normal mode).
    autocmd CmdwinEnter [:/?] startinsert

    autocmd VimResized * execute "normal! \<c-w>="
augroup END


" ------------------------------------------------------------------------------
" Whitespace
" ------------------------------------------------------------------------------

" Auto-indent blocks.
set autoindent
set smartindent

" Use shift-width for tabbing. Ignore tabstop & softtabstop.
set smarttab

" Four space tabs, and convert tabs to spaces.
set ts=4 sts=4 sw=4 expandtab

" Use nicer representations when showing invisible characters.
" set listchars=tab:\▸\ ,eol:·,extends:»,precedes:«,nbsp:✗,trail:⌴
set listchars=tab:\▸\ ,extends:»,precedes:«,nbsp:✗,trail:⌴
set showbreak=↪

" Show whitespace.
set list

" Auto-commands
augroup mt_whitespace
    autocmd!

    " Show trailing whitespace when out of insert mode.
    autocmd InsertEnter * :set listchars-=trail:⌴
    autocmd InsertLeave * :set listchars+=trail:⌴

    " Should probably be doing this sort of thing with ft plugin, indent et al...
    " Use 2-space tabs when editing a ruby file.
    autocmd Filetype ruby,yaml,haml,cucumber set ts=2 sts=2 sw=2 expandtab

    " Should probably be doing this sort of thing with ft plugin, indent et al...
    " Use 2-space tabs when editing an assembly file.
    autocmd Filetype asm set ts=2 sts=2 sw=2 expandtab

    " Seem to be getting the above in eruby too, which I don't want.
    " autocmd Filetype eruby set ts=4 sts=4 sw=4 expandtab
    " autocmd BufNewFile,BufRead *.ejs set filetype=eruby

    " Don't use vim-go's additional highlighting for trailing whitespace
    " since it's distracting in insert mode and we have our own version:
    let g:go_highlight_trailing_whitespace_error = 0

    " Don't highlight tabs in go files, since we're expected to use them:
    autocmd Filetype go :set listchars+=tab:\ \ 
    autocmd Filetype go :hi SpecialKey ctermfg=red ctermbg=none
augroup END


" ------------------------------------------------------------------------------
" Colouring
" ------------------------------------------------------------------------------

" Use fancy colours.
set t_Co=256

" Turn on syntax-highlighing.
syntax on

" Worthwhile schemes: elflord, molokai, mustang, matts-mustang, matts-light
if !$COLORFGBG || split($COLORFGBG, ';')[0] == '0'
    set background=light
    colorscheme matts-light
else
    set background=dark
    " colorscheme matts-mustang
    colorscheme matts-darkside
endif

" Briefly highlight matching bracket when completing a pair
set showmatch
set matchtime=1

" Auto-commands
augroup mt_colouring
    autocmd!

    " Highlight django template tags in html files.
    autocmd BufNewFile,BufRead *.twig set filetype=django
    autocmd FileType django set autoindent&
    autocmd FileType django set indentexpr&
augroup END


" Use bash instead of posix highlighting for .sh files.
" See `:help ft-bash-syntax`.
let g:is_bash = 1


" ------------------------------------------------------------------------------
" Searching
" ------------------------------------------------------------------------------

" Don't keep results highlighted after searching...
set nohlsearch
" ...just highlight as we type.
set incsearch

" Make /-style searches case-insensitive if the search string is all lowercase.
set ignorecase
set smartcase


" ------------------------------------------------------------------------------
" Key-mappings
" ------------------------------------------------------------------------------

" Move between wrapped lines as though they were physical lines.
noremap k gk
noremap j gj
noremap <up> g<up>
noremap <down> g<down>

" Move between splits without W-key when keyboard is misbehaving.
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Easier start & end of line.
noremap H ^
nnoremap L $
vnoremap L $h

" Open files relative to the path of the current file.
cnoremap %% <c-r>=expand('%:h').'/'<cr>

" A few readline-style key bindings taken from rsi.vim
" (https://github.com/tpope/vim-rsi)
inoremap <C-a> <C-o>^
cnoremap <C-a> <Home>
inoremap <expr> <C-e> col('.')>strlen(getline('.'))<bar><bar>pumvisible()?"\<Lt>C-E>":"\<Lt>End>"
silent! exe "set <F29>=\<Esc>b"
silent! exe "set <F30>=\<Esc>f"
noremap! <F29> <S-Left>
noremap! <F30> <S-Right>

" Quickly create a new paragraph:
nnoremap <leader>o o<c-o>o
nnoremap <leader>O O<c-o>O

" Unmap vim's default buffer-local section mappings
" otherwise our global ones will be over-ridden.
augroup mt_sections
    autocmd!

    autocmd FileType * silent! unmap <buffer> ]]
    autocmd FileType * silent! unmap <buffer> ][
    autocmd FileType * silent! unmap <buffer> [[
    autocmd FileType * silent! unmap <buffer> []
augroup END

" Next section start or end:
noremap <silent> ]] :call NextSection(0, 0, 0)<cr>
noremap <silent> ][ :call NextSection(0, 1, 0)<cr>
" Prev section start or end:
noremap <silent> [[ :call NextSection(1, 0, 0)<cr>
noremap <silent> [] :call NextSection(1, 1, 0)<cr>

" Next section start or end (visual):
vnoremap <silent> ]] :<c-u>call NextSection(0, 0, 1)<cr>
vnoremap <silent> ][ :<c-u>call NextSection(0, 1, 1)<cr>
" Prev section start or end (visual):
vnoremap <silent> [[ :<c-u>call NextSection(1, 0, 1)<cr>
vnoremap <silent> [] :<c-u>call NextSection(1, 1, 1)<cr>

" Jump to the start or end of the next section, where 'section'
" is defined as a group of one or more non-empty lines.
func! NextSection(backwards, sectionend, visual)
    if a:visual
        normal! gv
    endif

    " http://vimdoc.sourceforge.net/htmldoc/pattern.html#/\_^
    let pattern = '\_^\s*\n'
    let flags = 'W'

    " http://vimdoc.sourceforge.net/htmldoc/pattern.html#/\%^
    " http://vimdoc.sourceforge.net/htmldoc/pattern.html#/\%$
    if a:backwards
        let pattern = '(%^|' . pattern . ')'
        let flags = flags . 'b'
    else
        let pattern = '(%$|' . pattern . ')'
    endif

    " http://vimdoc.sourceforge.net/htmldoc/pattern.html#/\v
    if a:sectionend
        let pattern = '\v' . '\S[\s\n]*' . pattern
    else
        let pattern = '\v' . pattern . '\s*\S'
        let flags = flags . 'e'
    endif

    " http://vimdoc.sourceforge.net/htmldoc/eval.html#search()
    call search(pattern, flags)
endf


" Disable cursor-keys to encourage better hand position.
" noremap <up> <nop>
" noremap <down> <nop>
" noremap <left> <nop>
" noremap <right> <nop>
"
" inoremap <up> <nop>
" inoremap <down> <nop>
" inoremap <left> <nop>
" inoremap <right> <nop>

" Indent & unindent with tab & shift-tab.
nnoremap <tab> >>
nnoremap <s-tab> <<
vnoremap <tab> >gv
vnoremap <s-tab> <gv

" Return the cursor to its original position after pasting.
noremap p p`[
noremap P P`[

" Better linewise selection in/around HTML tags.
nnoremap Vit vitVkoj
nnoremap Vat vatV

" Enter command-mode with one less key-press.
noremap ; :

if has('unix')
    let s:uname = systemlist('uname')[0]
    if s:uname == "Darwin"
        " Backslash is in a different place on mac keyboards, so standardise.
        let mapleader="`"
        " We have a patched font installed for powerline, so we can use fancy symbols.
        " let g:Powerline_symbols = 'fancy'
    endif
endif

" Shortcuts for saving & closing the current window.
noremap <leader>w :update<cr>
noremap <leader>s :update<cr>
noremap <leader>W :write !sudo tee > /dev/null %<cr>
noremap <leader>d :quit<cr>

" Just a tiny bit quicker:
" noremap <leader>h :help<space>

" Toggle search highlighting:
noremap <leader>h :set hlsearch!<cr>

" Edit or reload the current config.
noremap <leader>v :vsplit $MYVIMRC<cr>
noremap <leader>u :source $MYVIMRC<cr>
" Edit or reload the current color scheme.
noremap <leader>vc :execute 'vsplit ' . ColorSchemePath()<cr>
noremap <leader>uc :execute 'colorscheme ' . g:colors_name<cr>

func! ColorSchemePath()
    let glob = 'colors/' . g:colors_name . '.vim'
    let path = split(globpath(&runtimepath, glob), "\n")[0]
    return path
endf

" Toggle invisible characters.
noremap <leader>i :set list!<cr>
" Toggle paste mode.
noremap <leader>p :set paste!<cr>

" Toggle the NERDTree file browser in a sidebar.
noremap <leader>e :NERDTreeToggle<cr>
" Toggle zooming (temporarily display only the current one of multiple windows).
noremap <leader>z :ToggleZoom<cr>
function! s:ToggleZoom() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction
command! ToggleZoom call s:ToggleZoom()

" Re-indent, remove trailing whitespace & convert tabs to spaces.
noremap <leader>t :execute "normal gg=G"<bar>execute "normal ''"<bar>%s/\s\+$//e<bar>retab<cr>

" Quickly switch between two most common white-space set-ups.
noremap <leader>2 :set ts=2 sts=2 sw=2 expandtab<cr>
noremap <leader>4 :set ts=4 sts=4 sw=4 expandtab<cr>

" Underline & double-underline.
noremap <leader>- Yp^v$r-
noremap <leader>= Yp^v$r=

" Show syntax highlighting groups for word under cursor
" See: http://vimcasts.org/episodes/creating-colorschemes-for-vim/
" nnoremap <leader>syn :call SynStack()<CR>
func! SynStack()
    if exists("*synstack")
        echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endif
endf

" Toggle wrapping and highlighting of long-lines.
noremap <leader>l :call ToggleWrapping()<cr>
func! ToggleWrapping()
    let ww = 80
    if &textwidth != ww
        let &textwidth = ww
        let w:long_line_match=matchadd('LongLine', '\%>'.ww.'v.\+', -1)
    else
        let &textwidth = 0
        if exists('w:long_line_match')
            call matchdelete(w:long_line_match)
            unlet w:long_line_match
        endif
    endif
    set colorcolumn=+1
endf

" Toggle between absolute and relative line-numbering.
noremap <leader>n :call ToggleNumbering()<cr>
func! ToggleNumbering()
    if exists("+relativenumber")
        set relativenumber!
    else
        set number!
    endif
endf

" Toggle the current word or selection between under_score & camelCase naming styles.
nmap <silent> <leader>_ mZviw<leader>_`Z
nmap <silent> <leader>c mZviw<leader>c`Z
vnoremap <silent> <leader>_ mz:call SnakeCaseSelection()<cr>`z
vnoremap <silent> <leader>c mz:call CamelCaseSelection()<cr>`z

func! SnakeCaseSelection()
    :s/\%V\([a-z]\)\([A-Z]\)/\1_\l\2/ge
endf

func! CamelCaseSelection()
    :s/\%V_\([a-z]\)/\u\1/ge
endf


" ------------------------------------------------------------------------------
" Miscellaneous
" ------------------------------------------------------------------------------

" Tell netrw to keep its history file in ~/.vim/tmp
let g:netrw_home = '~/.vim/tmp'

" Don't bother listing meta-file junk in NERDTree.
let NERDTreeIgnore = ['\.o$', '\.svn$', '\.pyc$', '\~$', '\.class$', '\.dSYM$']

" Customize the NERDTree UI a bit.
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeMouseMode = 2

" Prevent supertab.vim from clobbering our <cr> mapping below.
let g:SuperTabCrMapping = 0

" Don't render tag contents with bold, italic & underline in HTML.
let html_no_rendering=1

" Insert Python debug snippet.
nnoremap <f9> Oimport pdb; pdb.set_trace()<esc>
inoremap <f9> import pdb; pdb.set_trace()

nnoremap <f10> Oimport ipdb; ipdb.set_trace()<esc>
inoremap <f10> import ipdb; ipdb.set_trace()

" Insert Python boilerplate.
" func! LoadTemplate()
"     silent! 0r ~/.vim/skel/tmpl.%:e
" endf
"
" nnoremap <f10> :call LoadTemplate()<cr>
" inoremap <f10> <esc>:call LoadTemplate()<cr>

" Auto-commands
augroup mt_miscellaneous
    autocmd!

    " Load file template with boilerplate based on file extension.
    " autocmd BufNewFile * call LoadTemplate()

    " Open help in a vertical split.
    autocmd FileType help wincmd L
augroup END


" ------------------------------------------------------------------------------
" Auto-closing pairs
" ------------------------------------------------------------------------------

" Define some pair types (currently only used when deleting).
let g:autopairs = ['(:)', '[:]', '{:}', '":"', "':'", '<:></>', '<:>', '{% : %}', '{{ : }}', '<% : %>', '<%= : %>']

" Pairing for basic brace types (round, square & curly).
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>

" Angle-brackets are more likely to appear individually than other brace
" types (as less-than & greater-than) so don't auto-close them by default.
" But do provide leader combos for creating tags (standard & self-closing).
inoremap <leader><lt> <lt>><lt>/><left><left><left><left>
inoremap <leader>> <lt>><left>

" Gracefully handle over-writing of auto-closed pairs.
inoremap <expr> ) ClosePair(')')
inoremap <expr> ] ClosePair(']')
inoremap <expr> } ClosePair('}')
inoremap <expr> > ClosePair('>')

" Quotes are a bit more complicated.
inoremap <expr> " CloseQuote('"')
inoremap <expr> ' CloseQuote("'")

" Non-auto-closing mappings for convenience.
inoremap <leader>( (
inoremap <leader>[ [
inoremap <leader>{ {
inoremap <leader>" "
inoremap <leader>' '

" Wrap visual selections (using leader to avoid conflict with motions, etc)
vnoremap <leader>( s()<left><c-r>"<esc>
vnoremap <leader>[ s[]<left><c-r>"<esc>
vnoremap <leader>{ s{}<left><c-r>"<esc>
vnoremap <leader>" s""<left><c-r>"<esc>
vnoremap <leader>' s''<left><c-r>"<esc>
vnoremap <leader>` s``<left><c-r>"<esc>
vnoremap <leader><lt> s<lt>></><left><left><left><c-r>"<esc>`[<left>i
vnoremap <leader>> s<lt>><left><c-r>"<esc>

vnoremap <leader>h s{% header_link "" %}<left><left><left><left><c-r>"<esc>

" Delete auto-pairs as quickly as you can create them.
inoremap <expr> <bs> DeleteEmptyPair()
" Return inside an auto-pair snaps it open and indents.
inoremap <expr> <cr> SplitEmptyPair()

augroup mt_pairs
    autocmd!

    " Add mappings for rails / erb.
    " autocmd Filetype html,eruby,ejs inoremap <buffer> <leader>% <%<space><space>%><left><left><left>
    " autocmd Filetype html,eruby,ejs inoremap <buffer> <leader>= <%=<space><space>%><left><left><left>

    " And some for django / jinja / liquid.
    " autocmd Filetype html,htmldjango,django inoremap <buffer> <leader>{ {{<space><space>}}<left><left><left>
    " autocmd Filetype html,htmldjango,django inoremap <buffer> <leader>% {%<space><space>%}<left><left><left>

    autocmd Filetype php inoremap <buffer> <leader>? <lt>?php<space><space>?><left><left><left>

    " Auto-complete html end tags based on edits to the start tag.
    autocmd CursorMovedI * call CompleteTag()
augroup END


" ------------------------------------------------------------------------------
" A library of functions supporting the auto-pair mappings above.
" ------------------------------------------------------------------------------

func! ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<right>"
    else
        return a:char
    endif
endf

func! CloseQuote(char)
    let row = getline('.')
    let col = col('.')

    let prev = row[col - 2]
    let next = row[col - 1]

    if prev == "\\"
        " Inserting a quoted quotation mark into the string.
        return a:char
    elseif a:char == "'" && next != a:char && IsAlpha(prev)
        " Probably just want an apostrophe.
        return a:char
    elseif next == a:char
        " Closing the pair, just move the cursor.
        return "\<right>"
    else
        " Opening a pair, auto-close it.
        return a:char.a:char."\<left>"
    endif
endf

func! IsAlpha(c)
    let n = char2nr(a:c)
    if (n >= 65 && n <= 90) || (n >= 97 && n <= 122)
        return 1
    else
        return 0
    endif
endf

func! InAnEmptyPair(pairs)
    let cur = strpart(getline('.'), col('.')-2, 2)
    for pair in a:pairs
        if cur == join(split(pair,':'),'')
            return 1
        endif
    endfor
    return 0
endf

func! InASplitPair(pairs)
    let row = line('.')
    let prev_row = getline(row - 1)
    let curr_row = getline(row)
    let next_row = getline(row + 1)
    for pair in a:pairs
        let a = pair[0]
        let b = pair[2]
        if match(prev_row, a . '\s*$') != -1 && match(curr_row, '^\s*$') != -1 && match(next_row, '^\s*' . b) != -1
            return 1
        endif
    endfor
    return 0
endf

func! SurroundingTag()
    let [row_a, col_a] = searchpos('<','nbW')
    let [row_b, col_b] = searchpos('>','ncW')

    if row_a && row_b
        let lines = getline(row_a, row_b)
        let lines[0] = strpart(lines[0], col_a - 1)
        let lines[-1] = strpart(lines[-1], 0, col_b)

        return join(lines, "\n")
    else
        return ''
    endif
endf

func! InAnEmptyTag()
    return -1 < match(SurroundingTag(), '<\(\w*\)[^>]*><\/\1>')
endf

func! InASplitTag()
    return -1 < match(SurroundingTag(), '<\(\w*\)[^>]*>\n\s\+\n\s*<\/\1>')
endf

func! DeleteEmptyPair()
    let pairs = split(&matchpairs,',') + ['<:>','":"',"':'"]
    if InASplitPair(pairs) || InASplitTag()
        return "\<esc>kJJhxi"
    " elseif InAnEmptyTag()
    "     return "\<left>"
    else

        let line_str = getline('.')
        let c = col('.')
        for pair in g:autopairs
            let pair_arr = split(pair, ':')
            let pair_a = pair_arr[0]
            let pair_b = pair_arr[1]
            let pair_str = join(pair_arr, '')

            let curr_a = strpart(line_str, c - 1 - len(pair_a), len(pair_a))
            let curr_b = strpart(line_str, c - 1, len(pair_b))

            if curr_a == pair_a && curr_b == pair_b
                return "\<c-o>" . len(curr_a) . "X" . "\<c-o>" . len(curr_b) . "x"
            endif
        endfor

        return "\<bs>"

    endif
endf

func! SplitEmptyPair()
    let pairs = split(&matchpairs,',') + ['<:>','":"',"':'"]
    if InAnEmptyPair(pairs) || InAnEmptyTag()
        " return "\<cr>\<cr>\<up>\<tab>"
        " return "\<c-o>x\<cr>\<c-r>\"\<left>\<cr>\<up>\<tab>"
        return "\<cr>\<up>\<c-o>A\<cr>"
    else
        return "\<cr>"
    endif
endf

func! CompleteTag()
    let line = getline('.')
    let col = col('.')
    if line[col - 1] == '>'
        let line_a = strpart(line, 0, col)
        let line_a_idx = strridx(line_a, '<')
        let line_a = strpart(line_a, line_a_idx)

        let line_b = strpart(line, col)
        let line_b_idx = stridx(line_b, '>') + 1
        let line_b = strpart(line_b, 0, line_b_idx)

        let old_tag = line_a . line_b
        if match(old_tag, '^<[^/> ]*>.*</[^>]*>$') != -1
            let new_tag = substitute(old_tag, '^<\([^/> ]*\)>\(.*\)</[^>]*>$', '<\1>\2</\1>', '')
            let line = strpart(line, 0, line_a_idx) . new_tag . strpart(line, line_a_idx + strlen(old_tag))
            call setline('.', line)
        endif
    endif
endf
