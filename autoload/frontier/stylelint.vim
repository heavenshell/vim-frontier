let s:save_cpo = &cpo
set cpo&vim

function! s:parse(results)
  let outputs = []
  for k in a:results
    let filename = fnamemodify(k['source'], ':t')
    for w in k['warnings']
      let line = w['line']
      let start = w['column']
      let text = w['text']
      call add(outputs, {
            \ 'filename': filename,
            \ 'lnum': line,
            \ 'col': start,
            \ 'vcol': 0,
            \ 'text': printf('[Stylelint] %s', text),
            \ 'type': 'E'
            \})
    endfor
  endfor
  return outputs
endfunction

function! s:callback(ch, msg, mode)
  let results = json_decode(a:msg)
  let outputs = s:parse(results)
  if len(outputs) == 0 && len(getqflist()) == 0
    " No Errors. Clear quickfix then close window if exists.
    call setqflist([], 'r')
    cclose
  endif

  " If mode is 'a', add outputs to existing list.
  call setqflist(outputs, a:mode)
  if len(outputs) > 0 && g:frontier_enable_quickfix == 1
    cwindow
  else
    cclose
  endif
  redraw!
endfunction

function! frontier#stylelint#run(...)
  redraw | echomsg '[Frontier] Running stylelint'
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif

  let mode = a:0 > 0 ? a:1 : 'r'
  let file = expand('%:p')
  let cmd = printf('%s --formatter json %s', frontier#cmd('stylelint'), file)
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m, mode)},
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
