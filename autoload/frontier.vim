" File: frontier.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage: http://github.com/heavenshell/vim-frontier
" Description: Vim plugin for frontend development.
" License: BSD, see LICENSE for more details.

let s:save_cpo = &cpo
set cpo&vim

let s:root_path = ''
let s:commands = {
      \ 'eslint': '',
      \ 'stylelint': '',
      \ }

function! frontier#detect_root()
  if s:root_path != ''
    return s:root_path
  endif

  let path = expand('%:p')
  let root_path = finddir('node_modules', path . ';')
  let s:root_path = root_path

  return root_path
endfunction

function! s:detect_command_path(cmd)
  let bin = ''
  if executable(a:cmd) == 0
    let root_path = frontier#detect_root()
    let bin = root_path . '/.bin/' . a:cmd
  else
    let bin = exepath(a:cmd)
  endif

  return bin
endfunction

function! frontier#cmd(name)
  if s:commands[a:name] != ''
    return s:commands[a:name]
  endif

  let cmd = s:detect_command_path(a:name)
  let s:commands[a:name] = cmd

  return cmd
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
