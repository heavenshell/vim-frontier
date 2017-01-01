# vim-frontier

My frontend(JavaScript) vim plugins pack.

- Eslint
  - Run with job and channel
- Stylelint
  - Run with job and channel
- Mocha
  - Quickrun plugin

## Features

- Run eslint realtime
  - It detect source code change immediately and upddate results(no need to save buffer).
- Support `eslint --fix`
  - Experimental feature

## Settings

Example settings.

- Run Eslint.
- Run [vim-flood](https://github.com/heavenshell/vim-flood).
- Update [QuickfixStatus](https://github.com/dannyob/quickfixstatus/)
- Update [vim-hier(forked version)](https://github.com/cohama/vim-hier)

```viml
augroup js_enable_quickfix
  autocmd!
  function! s:js_quickfix()
    " Clear QuickFix.
    call setqflist([], 'r')
    call frontier#eslint#run('a')
    " Run realtime check.
    call flood#check_contents#run('a')
  endfunction

  function! s:frontier_after(...)
    execute ':QuickfixStatusEnable'
    execute ':HierUpdate'
  endfunction

  autocmd BufWritePost *.js,*.jsx silent! call s:js_quickfix()
  autocmd InsertLeave *.js,*.jsx silent! call s:js_quickfix()
  autocmd TextChanged,TextChangedI *.js,*.jsx silent! call s:js_quickfix()
augroup END
```
