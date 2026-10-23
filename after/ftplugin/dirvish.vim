" File operations for dirvish buffers. Dirvish itself is read-only; these
" mappings act on the path under the cursor.
if exists('b:did_dirvish_fileops')
  finish
endif
let b:did_dirvish_fileops = 1

function! s:dir() abort
  let l:dir = expand('%')
  return l:dir[-1:] ==# '/' ? l:dir : l:dir . '/'
endfunction

function! s:cursor_path() abort
  return substitute(getline('.'), '[\/]\+$', '', '')
endfunction

function! s:new_file() abort
  let l:name = input('New file: ')
  if empty(l:name)
    return
  endif

  let l:path = s:dir() . l:name
  if !empty(getftype(l:path))
    echohl WarningMsg | echomsg 'Already exists: ' . l:path | echohl None
    return
  endif

  execute 'edit' fnameescape(l:path)
endfunction

function! s:new_dir() abort
  let l:name = input('New directory: ')
  if empty(l:name)
    return
  endif

  let l:path = s:dir() . l:name
  if !empty(getftype(l:path))
    echohl WarningMsg | echomsg 'Already exists: ' . l:path | echohl None
    return
  endif

  if mkdir(l:path, 'p') != 1
    echohl WarningMsg | echomsg 'Could not create: ' . l:path | echohl None
    return
  endif

  Dirvish
endfunction

function! s:rename() abort
  let l:old = s:cursor_path()
  if empty(l:old)
    return
  endif

  let l:name = input('Rename ' . fnamemodify(l:old, ':t') . ' to: ')
  if empty(l:name)
    return
  endif

  let l:new = fnamemodify(l:old, ':h') . '/' . l:name
  if l:new ==# l:old
    return
  endif

  if !empty(getftype(l:new))
    echohl WarningMsg | echomsg 'Already exists: ' . l:new | echohl None
    return
  endif

  if rename(l:old, l:new) != 0
    echohl WarningMsg | echomsg 'Rename failed: ' . l:old | echohl None
    return
  endif

  Dirvish
endfunction

function! s:delete() abort
  let l:path = s:cursor_path()
  if empty(l:path)
    return
  endif

  let l:what = isdirectory(l:path) ? 'directory and its contents' : 'file'
  if confirm('Delete ' . l:what . ' ' . l:path . '?', "&Yes\n&No", 2) != 1
    return
  endif

  if delete(l:path, isdirectory(l:path) ? 'd' : '') != 0
    echohl WarningMsg | echomsg 'Delete failed: ' . l:path | echohl None
    return
  endif

  Dirvish
endfunction

nnoremap <buffer> <silent> <leader>n :<C-u>call <SID>new_file()<CR>
nnoremap <buffer> <silent> <leader>N :<C-u>call <SID>new_dir()<CR>
nnoremap <buffer> <silent> <leader>r :<C-u>call <SID>rename()<CR>
nnoremap <buffer> <silent> <leader>d :<C-u>call <SID>delete()<CR>

nnoremap <buffer> <silent> <leader>c :<C-u>Shdo cp -r {}<Space>
xnoremap <buffer> <silent> <leader>c :Shdo cp -r {}<Space>
nnoremap <buffer> <silent> <leader>m :<C-u>Shdo mv {}<Space>
xnoremap <buffer> <silent> <leader>m :Shdo mv {}<Space>
