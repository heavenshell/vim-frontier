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
    if len(outputs) == 0 && len(getqflist()) == 0
      " No Errors. Clear quickfix then close window if exists.
      call setqflist([], 'r')
      cclose
    endif
    return
  endif

  " If mode is 'a', add outputs to existing list.
  call setqflist(outputs, a:mode)
  if len(outputs) > 0 && g:flood_enable_quickfix == 1
    cwindow
  else
    cclose
  endif
  redraw!
endfunction

function! frontier#eslint#run(...)
  redraw | echomsg '[Frontier] Running eslint'
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif

  let mode = a:0 > 0 ? a:1 : 'r'
  let file = expand('%:p')
  let cmd = printf('%s --format json --ext .js,.jsx  %s', frontier#cmd('eslint'), file)
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m, mode)},
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

