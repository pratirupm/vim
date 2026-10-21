" Compact netrw cheat sheet. Press ? in the explorer.
function! s:close_popup(id, key) abort
  if a:key ==# '?' || a:key ==# 'q' || a:key ==# "\<Esc>" || a:key ==# "\<CR>"
    call popup_close(a:id)
    return 1
  endif
  return 0
endfunction

function! s:netrw_cheatsheet() abort
  let l:lines = [
        \ ' NETRW QUICK ACTIONS',
        \ '',
        \ ' Create',
        \ '   %    new file',
        \ '   d    new directory',
        \ '',
        \ ' Change',
        \ '   D    delete file or directory',
        \ '   R    rename file or directory',
        \ '',
        \ ' Copy / move',
        \ '   mf   mark file(s)',
        \ '   mt   set target directory',
        \ '   mc   copy marked files to target',
        \ '   mm   move marked files to target',
        \ '   mu   unmark all',
        \ '',
        \ ' <CR> open file / expand folder   - up',
        \ ' <C-l> refresh   <F1> full help   ? close',
        \ ]

  call popup_create(l:lines, {
        \ 'title': ' netrw ',
        \ 'border': [],
        \ 'borderhighlight': ['Title'],
        \ 'padding': [0, 1, 0, 1],
        \ 'pos': 'center',
        \ 'zindex': 200,
        \ 'filter': function('s:close_popup'),
        \ })
endfunction

nnoremap <buffer> <silent> <nowait> ? :<C-u>call <SID>netrw_cheatsheet()<CR>
command! -buffer NetrwCheatSheet call s:netrw_cheatsheet()
