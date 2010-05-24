" set backupdir=~/backups
"
"set background=torte
syntax on

" turn off the goddamned bell
set vb

map <F11> :let &background = ( &background == "dark"? "light" : "dark" )<CR> map <F10> :set number<CR> map <F9> :set nonumber<CR> colorscheme torte map <F12> : make

set makeprg=ant\ release
set efm=%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#


" Following shamelessly stolen from Max Cantor " "zo" to open folds, "zc" to close, "zn" to disable.

" Basic Settings {{{1

" set nocompatible      " This should be set automatically upon detection of .vimrc


" Activate auto filetype detection
filetype plugin indent on
syntax enable

set tags=./tags,tags,~/tags

set ignorecase          " Don't care about case...
set smartcase		" ... unless the query contains upper case characters
set autoindent		" Enable automatic indenting for files with ft set
"set nowrap		" No fake carriage returns
set showcmd		" Show command in statusline as it's being typed
set showmatch		" Jump to matching bracket
set ruler		" Show row,col %progress through file
set laststatus=2	" Always show filename (2 is always)
set hidden	    	" Let us move between buffers without writing them.  Don't :q! or :qa! frivolously!
set softtabstop=4	" Vim sees 4 spaces as a tab
set shiftwidth=4	" < and > uses spaces
set expandtab		" Tabs mutate into spaces
"set foldmethod=indent	" Default folding
set backspace=indent,eol,start  " Make backspace work like other editors.
" set tabstop=4		" 4-space indents
" set smarttab		" <TAB> width determined by shiftwidth instead of tabstop.  


" Nicer highlighting of completion popup highlight Pmenu guibg=brown gui=bold

"function! CHANGE_CURR_DIR()
"    let _dir = expand("%:p:h")
"    exec "cd " . _dir
"    unlet _dir
"endfunction
"autocmd BufEnter * call CHANGE_CURR_DIR()

" }}}1

" Backups & .vimrc Editing (Filesystem-dependent) {{{1

if has('win32') 
    " Windows filesystem
    set directory=C:\VimBackups
    set backupdir=C:\VimBackups
    if($MYVIMRC == "")  " Pre-Vim 7
        let $MYVIMRC = $VIM."\_vimrc"
    endif
else
    " Linux filesystem
    set directory=$HOME/.backups//
    set backupdir=$HOME/.backups//
    if($MYVIMRC == "")  " Pre-Vim 7
        let $MYVIMRC = $HOME."/.vimrc"
    endif
endif

" }}}1

" Basic Key Mappings {{{1

" Switch to recent buffer
nnoremap K :b#<CR>

" Easy saving
nnoremap <C-u> :w<CR>
inoremap <C-u> <ESC>:w<CR>
vnoremap <C-u> <ESC>:w<CR>

" Create a new HTML document.
nnoremap ,html :set ft=html<CR>i<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><CR><html lang="en"><CR><head><CR><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><CR><title></title><CR><link rel="stylesheet" type="text/css" href="style.css"><CR><script type="text/javascript" src="script.js"></script><CR></head><CR><body><CR></body><CR></html><ESC>?title<CR>2hi

" Bind for easy pasting
set pastetoggle=<F12>

" Editing vimrc
nnoremap ,v :source $MYVIMRC<CR>
nnoremap ,e :edit $MYVIMRC<CR>

" Quickly change search hilighting
nnoremap ; :set invhlsearch<CR>

" Change indent continuously
vmap < <gv
vmap > >gv

" Movement between split windows
nnoremap <C-k> <C-w>k
nnoremap <C-j> <C-w>j
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" Fold everything but the parent class in a Ruby file nnoremap z, :set foldlevel=1<CR>

" Tabs
if exists( '*tabpagenr' ) && tabpagenr('$') != 1
    nnoremap ,V :tabdo source $MYVIMRC<CR>
    nnoremap tn :tabnew<CR>
    nnoremap tw :tabclose<CR>
else
    nnoremap ,V :bufdo source $MYVIMRC<CR> 
endif

" Turns visually selected camelCase into camel_case vnoremap ,case :s/\v\C(([a-z]+)([A-Z]))/\2_\l\3/g<CR>

" Session mappings
nnoremap ,s :mksession! Session.vim<CR>
nnoremap ,q :bufdo :w<CR>:mksession! Session.vim<CR>:qall<CR>

" }}}1

" Custom Functions {{{1
" Custom Function Key Mapping {{{2

" Movement between tabs OR buffers
nnoremap L :call MyNext()<CR>
nnoremap H :call MyPrev()<CR>

" Resizing split windows
nnoremap ,w :call SwapSplitResizeShortcuts()<CR>

" Easy changing for scrolloff
nnoremap ,b :call SwapBrowseMode()<CR>

" Wraps visual selection in an HTML tag
vnoremap ,w <ESC>:call VisualHTMLTagWrap()<CR>

" For Notepad-like handling of wrapped lines nnoremap ,n :call NotepadLineToggle()<CR>

" Quick function prototype
nnoremap ,f :call QuickFunctionPrototype()<CR>

" }}}2

" Custom Function Defaults {{{2

" Set defaults in an !exists clause so we don't clobber existing setting 
" if .vimrc is being sourced during an editing session (instead of on open).
if !exists( 'g:resizeshortcuts' )
    let g:resizeshortcuts = 'horizontal'
    nnoremap _ <C-w>-
    nnoremap + <C-w>+
endif

if !exists( 'g:browsemode' )
    let g:browsemode = 'nobrowse'
    set sidescrolloff=0
    set scrolloff=0
endif

if !exists( 'g:notepadlines' )
    let g:notepadlines = 'false'
endif

" }}}2

" Custom Function Definitions {{{2
" MyNext() and MyPrev(): Movement between tabs OR buffers {{{3 
function! MyNext()
    if exists( '*tabpagenr' ) && tabpagenr('$') != 1
	" Tab support && tabs open
	normal gt
    else
	" No tab support, or no tabs open
	execute ":bnext"
    endif
endfunction
function! MyPrev()
    if exists( '*tabpagenr' ) && tabpagenr('$') != '1'
	" Tab support && tabs open
	normal gT
    else
	" No tab support, or no tabs open
	execute ":bprev"
    endif
endfunction
" }}}3

" SwapSplitResizeShortcuts(): Resizing split windows {{{3 
function! SwapSplitResizeShortcuts()
    if g:resizeshortcuts == 'horizontal'
	let g:resizeshortcuts = 'vertical'
	nnoremap _ <C-w><
	nnoremap + <C-w>>
	echo "Vertical split-resizing shortcut mode."
    else
	let g:resizeshortcuts = 'horizontal'
	nnoremap _ <C-w>-
	nnoremap + <C-w>+
	echo "Horizontal split-resizing shortcut mode."
    endif
endfunction
" }}}3

" SwapBrowseMode(): Easy changing for scrolloff {{{3 
function! SwapBrowseMode()
    if g:browsemode == 'nobrowse'
	let g:browsemode = 'browse'
	set sidescrolloff=999
	set scrolloff=999
	echo "Browse mode enabled."
    else
	let g:browsemode = 'nobrowse'
	set sidescrolloff=0
	set scrolloff=0
	echo "Browse mode disabled."
    endif
endfunction
" }}}3

" VisualHTMLTagWrap(): Wraps visual selection in an HTML tag {{{3 
function! VisualHTMLTagWrap()
    let html_tag = input( "html_tag to wrap block: ")
    let jumpright = 2 + strlen( html_tag )
    normal `<
    let init_line = line( "." )
    exe "normal i<".html_tag.">"
    normal `>
    let end_line = line( "." )
    " Don't jump if we're on a new line
    if( init_line == end_line )
	" Jump right to compensate for the characters we've added
	exe "normal ".jumpright."l"
    endif
    exe "normal a</".html_tag.">"
endfunction
" }}}3

" QuickFunctionPrototype(): Quickly generate a function prototype. {{{3 
function! QuickFunctionPrototype()
    let function_name = input( "function name: ")
    if &ft == "php"
        " The extra a\<BS> startinsert! is because this function drops
        " out of insert mode when it finishes running, and startinsert
        " ignores auto-indenting.
        exe "normal ofunction ".function_name."(){\<CR>}\<ESC>Oa\<BS>"
        startinsert!
    else
        echo "Filetype not supported."
    endif
endfunction
" }}}3

" NotepadLineToggle(): For Notepad-like handling of wrapped lines {{{3 
function! NotepadLineToggle()
    if g:notepadlines == 'false'
	nnoremap j gj
	nnoremap k gk
	let g:notepadlines = 'true'
	set wrap
	echo "Notepad wrapped lines enabled."
    else
	unmap j
	unmap k
	let g:notepadlines = 'false'
	set nowrap
	echo "Notepad wrapped lines disabled."
    endif
endfunction
" }}}3
" }}}2
" }}}1

