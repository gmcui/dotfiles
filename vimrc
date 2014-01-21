" Create ~/.vimrc like the following:
"
" if filereadable(glob("~/dotfiles/vimrc"))
"   source ~/dotfiles/vimrc
" endif

" if you are using gvim or macvim
" set guifont=Menlo\ 11

" set autoindent
" set smartindent
set backspace=indent,eol,start

set ruler 
" set scrolloff=3

set tabstop=4
set softtabstop=4
set shiftwidth=4

set noexpandtab

set ignorecase
set smartcase

" set relativenumber

" show text wrap status
set laststatus=2
set statusline=%t%m\ %y\ %=[%c,%l]\ [%{&fo}]

" colorscheme molokai
" set background=dark
" colorscheme solarized
"
execute pathogen#infect()

syntax on
syntax sync minlines=1000

filetype plugin indent on

set hlsearch
set incsearch

highlight MatchParen ctermbg=blue guibg=lightblue

set tags=~/*/tags
hi Search ctermbg=LightBlue

set listchars=tab:>-,trail:-,eol:$

" set tmp dir for .swp files
if !isdirectory("~/tmp")
	silent !mkdir ~/tmp > /dev/null 2>&1
endif

set dir=~/tmp

" set undofile
" set undodir=~/tmp

" custom tab setting for file types
autocmd BufNewFile,BufRead *.thor set filetype=ruby
autocmd BufNewFile,BufRead *.json set filetype=json

autocmd FileType html,perl,php,python,smarty,javascript,java,sql,mysql
    \ setlocal tabstop=4 softtabstop=4 shiftwidth=4
autocmd FileType ruby,eruby,cucumber,yaml,haml,xml,coffee
    \ setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType perl,php,python,javascript,java,ruby,eruby,cucumber,yaml,haml,xml,sql,mysql,coffee
    \ setlocal expandtab

" set textwidth but do not auto wrap
autocmd FileType perl,php,smarty,javascript,ruby,eruby,cucumber
    \ setlocal textwidth=80 formatoptions-=t

autocmd FileType perl
    \ setlocal cindent cinkeys=0{,0},!^F,o,O,e

autocmd FileType javascript setlocal makeprg=jslint\ %
autocmd FileType perl       setlocal makeprg=/usr/local/bin/perl\ -cw\ %
autocmd FileType php        setlocal makeprg=php\ -l\ %
autocmd FileType python     setlocal makeprg=pylint\ -E\ %
autocmd FileType ruby       setlocal makeprg=ruby\ -c\ %

autocmd FileType json       command! -range=% -nargs=* Tidy <line1>,<line2>!json_xs -f json -t json-pretty
autocmd FileType javascript command! -range=% -nargs=0 Tidy <line1>,<line2>!beautify_js 
autocmd FileType perl       command! -range=% -nargs=0 Tidy <line1>,<line2>!perltidy -q

autocmd FileType html       command! Tidy %!tidy -i 2>/dev/null
autocmd FileType xml        command! Tidy silent %!xmllint --format --recover - 2>/dev/null

autocmd FileType perl       command! Pod read ~/.vim/pod.template
autocmd FileType perl       command! Run !./%
