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

let g:frontier_enable_init_onstart = get(g:, 'frontier_enable_init_onstart', 1)
if g:frontier_enable_init_onstart == 1
  call frontier#init()
endif

let b:loaded_frontier = 1

let &cpo = s:save_cpo
unlet s:save_cpo
