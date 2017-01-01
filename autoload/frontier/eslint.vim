" File: frontier#eslint.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage: http://github.com/heavenshell/vim-frontier
" Description: Vim plugin for frontend development.
" License: BSD, see LICENSE for more details.

let s:save_cpo = &cpo
set cpo&vim

function! s:parse(results)
  let outputs = []
  for k in a:results
    let messages = k['messages']
    let filename = fnamemodify(k['filePath'], ':t')
    for m in messages
      let line = m['line']
      let start = m['column']
      let text = m['message']

      call add(outputs, {
            \ 'filename': filename,
            \ 'lnum': line,
            \ 'col': start,
            \ 'vcol': 0,
            \ 'text': printf('[ESlint] %s (%s)', text, m['ruleId']),
            \ 'type': 'E'
            \})
    endfor
  endfor

  return outputs
endfunction

function! s:callback(ch, msg, mode)
  let results = json_decode(a:msg)
  let outputs = s:parse(results)
  if results[0]['errorCount'] == 0
    if g:frontier_enable_quickfix == 1 && len(outputs) == 0 && len(getqflist()) == 0
      " No Errors. Clear quickfix then close window if exists.
      call setqflist([], 'r')
      cclose
    endif
    return
  endif

  " If mode is 'a', add outputs to existing list.
  call setqflist(outputs, a:mode)
  if len(outputs) > 0 && g:frontier_enable_quickfix == 1
    cwindow
  endif

  if frontier#has_callback('eslint', 'after_run')
    call g:frontier_callbacks['eslint']['after_run']()
  endif
endfunction

function! s:exit_callback(ch, msg, mode)
  if frontier#has_callback('eslint', 'after_run')
    call g:frontier_callbacks['eslint']['after_run']()
  endif
endfunction

function! frontier#eslint#run(...)
  if frontier#has_callback('eslint', 'before_run')
    call g:frontier_callbacks['eslint']['before_run']()
  endif

  redraw | echomsg '[Frontier] Running eslint'
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif

  let mode = a:0 > 0 ? a:1 : 'r'
  let file = expand('%:p')
  let cmd = printf('%s --stdin --stdin-filename %s --format json --ext .js,.jsx', frontier#cmd('eslint'), file)
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m, mode)},
        \ 'exit_cb': {c, m -> s:exit_callback(c, m, mode)},
        \ 'in_io': 'buffer',
        \ 'in_name': file,
        \ })
endfunction

function! s:fix_callback(ch, msg, view) abort
  " `eslint --fix` rewrite file at background and save automatically.
  " So reload current file.
  :e!

  call winrestview(a:view)
endfunction

function! frontier#eslint#fix()
  if &filetype != 'javascript'
    return
  endif

  let view = winsaveview()
  let file = expand('%:p')
  let cmd = printf('%s --ext .js,.jsx --fix %s', frontier#cmd('eslint'), file)
  let s:job = job_start(cmd, {
        \ 'exit_cb': {c, m -> s:fix_callback(c, m, view)},
        \ 'in_io': 'buffer',
        \ 'in_name': file,
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
