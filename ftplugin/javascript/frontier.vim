let s:save_cpo = &cpo
set cpo&vim

if get(b:, 'loaded_frontier')
  finish
endif

" version check
if !has('channel') || !has('job')
  echoerr '+channel and +job are required for flood.vim'
  finish
endif

command! -buffer FrontierEslint         :call frontier#eslint#run()

noremap <silent> <buffer> <Plug>(FrontierEslint)          :FrontierEslint <CR>

let b:loaded_frontier = 1

let &cpo = s:save_cpo
unlet s:save_cpo
