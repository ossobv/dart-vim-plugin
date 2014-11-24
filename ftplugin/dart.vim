if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

" Enable automatic indentation (2 spaces) if variable g:dart_style_guide is set 
if exists('g:dart_style_guide')
  setlocal expandtab
  setlocal shiftwidth=2
  setlocal softtabstop=2

  setlocal formatoptions-=t
endif

" Set 'comments' to format dashed lists in comments.
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

setlocal commentstring=//%s
let s:win_sep = (has('win32') || has('win64')) ? '/' : ''
let &l:errorformat =
  \ join([
  \   ' %#''file://' . s:win_sep . '%f'': %s: line %l pos %c:%m',
  \   '%m'
  \ ], ',')


let b:undo_ftplugin = 'setl et< fo< sw< sts< com< cms<'

" Add mappings, unless the user didn't want this.
" The default mapping is registered under to <F7> by default, unless the user
" remapped it already (or a mapping exists already for <F7>)
if !exists("no_plugin_maps") && !exists("no_dart_maps")
    if !hasmapto('dart#DartAnalyzer(')
        noremap <buffer> <F7> :call dart#DartAnalyzer()<CR>
    endif
endif

let &cpo = s:save_cpo
unlet s:save_cpo
