# vim-frontier

My frontend(JavaScript) vim plugins pack.

- Eslint
  - Run with job and channel
- Stylelint
  - Run with job and channel
- Mocha
  - Quickrun plugin

## Settings

Run Eslint and [vim-flood](https://github.com/heavenshell/vim-flood) on save.

```viml
augroup js_enable_quickfix
  autocmd!
  let g:frontier_run_on_save = 0
  let g:frood_check_on_save = 0
  autocmd BufWritePost *.js,*.jsx silent! call s:_quickfix()
  "autocmd BufWritePost *.js,*.jsx
    \ silent! call flood#check#run('a') | call frontier#eslint#run('a')
augroup END
```
