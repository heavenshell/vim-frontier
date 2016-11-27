" File: frontier#eslint.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage: http://github.com/heavenshell/vim-frontier
" Description: Vim plugin for frontend development.
" License: BSD, see LICENSE for more details.

let s:save_cpo = &cpo
set cpo&vim

function! s:detect_config()
  let root = frontier#detect_root()
endfunction

function! s:parse(results)
  let outputs = []
  for k in a:results
    let messages = k['messages']
    let filename = fnamemodify(k['filePath'], ':t')
    for m in messages
      let line = m['line']
      let start = m['column']
      let text =  m['message']

      call add(outputs, {
            \ 'filename': filename,
            \ 'lnum': line,
            \ 'col': start,
            \ 'vcol': 0,
            \ 'text': text,
            \ 'type': 'E'
            \})
    endfor
  endfor

  return outputs
endfunction

function! s:callback(ch, msg)
  let results = json_decode(a:msg)
  if results[0]['errorCount'] == 0
    if len(getqflist()) == 0
      " No Errors. Clear quickfix then close window if exists.
      call setqflist([], 'r')
      cclose
    endif
    return
  endif

  let outputs = s:parse(results)

  call setqflist(outputs, 'r')
  if len(outputs) > 0 && g:flood_enable_quickfix == 1
    cwindow
  else
    cclose
  endif
endfunction

function! frontier#eslint#run()
  redraw | echomsg '[Frontier] Running eslint'
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif

  let file = expand('%:p')
  let cmd = printf('%s --format json --ext .js,.jsx  %s', frontier#cmd('eslint'), file)
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m)},
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

