" Find the path to this script so that the links
" to formatter don't need to be hard coded.
if !exists('g:SweetVimRspecPlugin')
  let g:SweetVimRspecPlugin = fnamemodify(expand("<sfile>"), ":p:h") 
endif

function! SweetVimRspecRun(kind)
  echomsg "Running Specs..."
  sleep 10m " Sleep long enough so MacVim redraws the screen so you can see the above message

  if !exists('g:SweetVimRspecUseBundler')
    let g:SweetVimRspecUseBundler = 1
  endif

  if !exists('t:SweetVimRspecVersion')
    let l:cmd = ""
    if g:SweetVimRspecUseBundler == 1
      let l:cmd .= "bundle exec "
    endif
    let l:cmd .=  "spec --version 2>/dev/null"
    " Execute the spec --version command which, if returns without error
    " means that the version of rspec is ONE otherwise assume rspec2
    cgete system( l:cmd ) 
    let t:SweetVimRspecVersion = v:shell_error == 0 ? 1 : 2
  endif

  if !exists('t:SweetVimRspecExecutable') || empty(t:SweetVimRspecExecutable)
    let t:SweetVimRspecExecutable =  g:SweetVimRspecUseBundler == 0 ? "" : "bundle exec " 
    if  t:SweetVimRspecVersion  > 1
      let t:SweetVimRspecExecutable .= "rspec -r " . g:SweetVimRspecPlugin . "/sweet_vim_rspec2_formatter.rb" . " -f RSpec::Core::Formatters::SweetVimRspecFormatter "
    else
      let t:SweetVimRspecExecutable .= "spec -br " . g:SweetVimRspecPlugin . "/sweet_vim_rspec1_formatter.rb" . " -f Spec::Runner::Formatter::SweetVimRspecFormatter "
    endif
  endif
  
  if a:kind !=  "Previous" 
    let t:SweetVimRspecTarget = expand("%:p") . " " 
    if a:kind == "Focused"
      let t:SweetVimRspecTarget .=  "-l " . line(".") . " " 
    endif
  endif

  if !exists('t:SweetVimRspecTarget')
    echo "Run a Spec first"
    return
  endif

  cclose

  if exists('g:SweetVimRspecErrorFile') 
    execute 'silent! bdelete ' .  g:SweetVimRspecErrorFile
  endif

  let g:SweetVimRspecErrorFile = tempname()
  execute 'silent! wall'
  cgete system(t:SweetVimRspecExecutable . t:SweetVimRspecTarget . " 2>" . g:SweetVimRspecErrorFile)
  botright cwindow
  cw
  setlocal foldmethod=marker
  setlocal foldmarker=+-+,-+-

  if getfsize(g:SweetVimRspecErrorFile) > 0 
    execute 'silent! split ' . g:SweetVimRspecErrorFile
    setlocal buftype=nofile
    "Shortcuts taken from Ack.vim - git://github.com/mileszs/ack.vim.git
    exec "nnoremap <silent> <buffer> q :ccl<CR>"
    exec "nnoremap <silent> <buffer> t <C-W><CR><C-W>T"
    exec "nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W><C-W>"
    exec "nnoremap <silent> <buffer> o <CR>"
    exec "nnoremap <silent> <buffer> go <CR><C-W><C-W>"
    exec "nnoremap <silent> <buffer> h <C-W><CR><C-W>K"
    exec "nnoremap <silent> <buffer> H <C-W><CR><C-W>K<C-W>b"
    exec "nnoremap <silent> <buffer> v <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t"
    exec "nnoremap <silent> <buffer> gv <C-W><CR><C-W>H<C-W>b<C-W>J"
  endif

  call delete(g:SweetVimRspecErrorFile)

  let l:oldCmdHeight = &cmdheight
  let &cmdheight = 2
  echo "Done"
  let &cmdheight = l:oldCmdHeight
endfunction
command! SweetVimRspecRunFile call SweetVimRspecRun("File")
command! SweetVimRspecRunFocused call SweetVimRspecRun("Focused")
command! SweetVimRspecRunPrevious call SweetVimRspecRun("Previous")
