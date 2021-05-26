" 2016/11/16

" Add numbers by default
set number

" 2017-03-28
" Use solarized colourscheme in both terminal and in vim
" - this only works if the "solarized" palette is chosen in
"    Terminal::ProfilePreferences
syntax enable
" set background=light

" If using pathogen to manage vim addons (eg of colorschemes) you must
" be running pathogen before calling any addons that depend upon it
execute pathogen#infect()

" TODO: find a way to use this vimrc on both windows WSL and linux
"     - perhaps upgrade WSL first

" let g:solarized_termcolors=256
" set t_Co=256
" set term=xterm-256color

" Ensure the background-erase doesn't happen:
set term=screen-256color
set t_ut=

" Can't use has("win32") to distinguish WSL from native Ubuntu
" so we use this to ensure monokai is used on WSL and solarized on Ubuntu
"if matchstr(system("uname -a"), "Microsoft") == ""
"  colorscheme solarized
"else
  colorscheme monokai
"endif

" 2017-05-30
" Use solarized-light until 16.59, use solarized-dark afterwards
if strftime("%H") < 17
  set background=light
else
  set background=dark
endif

" 2017-06-12
" Add Pathogen, Syntastic and the R-linting program `lintr`
" and change the defaults or disregard some of the linters
" We drop the commented_code linter (this flags commented dates) and the
"   multiple_dots_linter (so that variables can have.this.kind.of.name)
" May have to drop 'object_length_linter'
" `lintr` must be installed in the environment for any job that uses R

" pathogen:  https://github.com/tpope/vim-pathogen
" syntastic: https://github.com/vim-syntastic/syntastic
" lintr:     https://github.com/jimhester/lintr


set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" 2017-11-21
" The following makes Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" 2017-01-04
" Turn off the bell sound in vim (really annoying in windows WSL)
" - by converting bell sound to visual bell and then clearing the visual bell
" length
set visualbell
set t_vb=

" 2018-01-18
" Visually convert trailing spaces into "." and tabs into >~
set listchars=tab:>~,trail:.
set list
" example:   	      		   

" 2018-01-24
" Expand tabs into spaces
set expandtab
set shiftwidth=2

" 2018-04-20
" Use unix line endings
set ff=unix

" --------------------------------------------------------------------------- "

" Line widths

" General:
" Turn the 100th column red and set the default text width to 99
" - Do this after setting the `colorscheme`
" - turn off auto-text-wrapping after the 99th character by `:set tw=0` in vim
set colorcolumn=100
set textwidth=99
highlight ColorColumn ctermbg=grey guibg=grey
call matchadd('ColorColumn', '\%101v', 100) "set column nr

" Specific File Types:
" Ensure git commits wrap text at column 72
au FileType gitcommit setlocal tw=72

" --------------------------------------------------------------------------- "

" Language specific stuff:
" - ensure filetype-detection evokes the correct vim plugin
filetype plugin indent on

" Rust
" - rust.vim was added on 2019-11-06
" - format on saving
let g:rustfmt_autosave = 1

" Python
" - add pylint as default linter for python
let g:syntastic_python_checkers = ['pylint']

" HTML
" - Would like to find an .html linter that plays nicely with Django templating
"   language
" - Have tried (and disregarded):
"   - 'tidy' (doesn't like Django templates)
"   - 'html_lint.py' (`https://pypi.org/project/html-linter/` - couldn't
"   configure it for use in syntastic)

" Javascript
" - Use eslint for linting / checking
" - and prettier for code styling (here, set to run on save)
let g:syntastic_javascript_eslint_exec = '/bin/ls'
let g:syntastic_javascript_eslint_exe = 'npm run lint --'
let g:syntastic_javascript_checkers = ['eslint']
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue PrettierAsync

" Snakemake
" - Syntax highlighting
" - After adding https://bitbucket.org/snakemake/snakemake/raw/master/misc/vim/
"   ... /syntax/snakemake.vim
"   to ~/.vim/syntax/
" - This enables snakemake colourschemes inside vim for Snakefile, snake.* and
"   *.smk files
au BufNewFile,BufRead Snakefile set syntax=snakemake
au BufNewFile,BufRead *.smk     set syntax=snakemake
au BufNewFile,BufRead snake.*   set syntax=snakemake

" R
" - Align arguments myself:
let r_indent_align_args = 0

" - Use 'lintr >= 2.0.0' for code consistency
"
" 'spaces_left_parentheses_linter' disagrees with styler defaults for
" statements like '- (1:3)' and '-(1:3)'; therefore dropped this linter

" 'open_curly_linter' disagrees with styler defaults for isolated code blocks
" like
" |lintr version|          |styler version|
" tryCatch({            => tryCatch(
"   my_dirty_code()     =>   {
"   })                  =>     my_dirty_code()
"                       =>   })
" therefore dropped 'open_curly_linter'

let lintr_list = ["assignment_linter = NULL",
                  \"commented_code_linter = NULL",
                  \"line_length_linter(100)",
                  \"object_length_linter(40)",
                  \"object_usage_linter = NULL",
                  \"open_curly_linter = NULL",
                  \"spaces_left_parentheses_linter = NULL"
                  \]
let lintr_string = join(lintr_list, ',')

let g:syntastic_enable_r_lintr_checker = 1
let g:syntastic_enable_rmd_lintr_checker = 1

let g:syntastic_r_checkers = ['lintr']
let g:syntastic_rmd_checkers = ['lintr']

let g:syntastic_r_lintr_linters = "with_defaults("
                                  \. lintr_string
                                  \. ")"
let g:syntastic_rmd_lintr_linters = "with_defaults("
                                   \. lintr_string
                                   \. ")"
