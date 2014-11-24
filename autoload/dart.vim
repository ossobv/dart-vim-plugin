"
" Dart filetype plugin
" Language:     Dart (ft=dart)
" Version:      Vim 7 (may work with lower Vim versions, but not tested)
" URL:          https://github.com/dart-lang/dart-vim-plugin
"
" Based on the excellent vim-flake8 plugin.
" https://github.com/nvie/vim-flake8

let s:save_cpo = &cpo
set cpo&vim

"" ** external ** {{{

function! dart#DartAnalyzer()
    call s:Analyzer()
endfunction

function! dart#DartUnplaceMarkers()
    call s:UnplaceMarkers()
endfunction

"" }}}

"" ** internal ** {{{

"" config

function! s:DeclareOption(name, globalPrefix, default)  " {{{
    if !exists('g:'.a:name)
        if a:default != ''
            execute 'let s:'.a:name.'='.a:default
        else
            execute 'let s:'.a:name.'=""'
        endif
    else
        execute 'let l:global="g:".a:name'
        if l:global != ''
            execute 'let s:'.a:name.'="'.a:globalPrefix.'".g:'.a:name
        else
            execute 'let s:'.a:name.'=""'
        endif
    endif
endfunction  " }}}

function! s:Setup()  " {{{
    "" read options

    " dart analyzer command
    call s:DeclareOption('dart_analyzer_cmd', '', '"dartanalyzer"')
    " dart analyzer options
    call s:DeclareOption('dart_analyzer_sdk',          ' --dart-sdk=',     '')
    call s:DeclareOption('dart_analyzer_package_root', ' --package-root=', '')
    " quickfix
    call s:DeclareOption('dart_quickfix_location', '', '"belowright"')
    call s:DeclareOption('dart_show_quickfix',     '', 1)
    " markers to show
    call s:DeclareOption('dart_show_in_gutter', '',   0)
    call s:DeclareOption('dart_show_in_file',   '',   0)
    call s:DeclareOption('dart_max_markers',    '', 500)
    " marker signs
    call s:DeclareOption('dart_error_marker',   '', '"E>"')
    call s:DeclareOption('dart_warning_marker', '', '"W>"')

    "" setup markerdata

    if !exists('s:markerdata')
        let s:markerdata = {}
        let s:markerdata['E'] = { 'name': 'Dart_Error'      }
        let s:markerdata['W'] = { 'name': 'Dart_Warning'    }
    endif
    let s:markerdata['E'].marker = s:dart_error_marker
    let s:markerdata['W'].marker = s:dart_warning_marker
endfunction  " }}}

"" do dart analyzer

function! s:Analyzer()  " {{{
    " read config
    call s:Setup()

    if !executable(s:dart_analyzer_cmd)
        echoerr "File " . s:dart_analyzer_cmd. " not found. Please install it first."
        return
    endif

    " clear old
    call s:UnplaceMarkers()
    let s:matchids = []
    let s:signids  = []

    " store old grep settings (to restore later)
    let l:old_gfm=&grepformat
    let l:old_gp=&grepprg
    let l:old_shellpipe=&shellpipe

    " write any changes before continuing
    if &readonly == 0
        update
    endif

    set lazyredraw   " delay redrawing
    cclose           " close any existing cwindows

    " set shellpipe to 2> instead of tee (suppressing output)
    set shellpipe=2>

    " perform the grep itself
    let &grepformat="%t%*[^|]|%*[^|]|%*[^|]|%f|%l|%c|%*[^|]|%m"
    let &grepprg=s:dart_analyzer_cmd.s:dart_analyzer_sdk.s:dart_analyzer_package_root." --format=machine"
    silent! grep! "%"

    " restore grep settings
    let &grepformat=l:old_gfm
    let &grepprg=l:old_gp
    let &shellpipe=l:old_shellpipe

    " process results
    let l:results=getqflist()
    let l:has_results=results != []
    if l:has_results
        " markers
        if !s:dart_show_in_gutter == 0 || !s:dart_show_in_file == 0
            call s:PlaceMarkers(l:results)
        endif
        " quickfix
        if !s:dart_show_quickfix == 0
            " open cwindow
            execute s:dart_quickfix_location." copen"
            setlocal wrap
            nnoremap <buffer> <silent> c :cclose<CR>
            nnoremap <buffer> <silent> q :cclose<CR>
        endif
    endif

    set nolazyredraw
    redraw!

    " Show status
    if l:has_results == 0
        echon "Dart check OK"
    else
        echon "Dart analyzer found issues"
    endif
endfunction  " }}}

"" markers

function! s:PlaceMarkers(results)  " {{{
    " in gutter?
    if !s:dart_show_in_gutter == 0
        " define signs
        for val in values(s:markerdata)
            if val.marker != ''
                execute "sign define ".val.name." text=".val.marker." texthl=".val.name
            endif
        endfor
    endif

    " place
    let l:index0 = 100
    let l:index  = l:index0
    for result in a:results
        if l:index >= (s:dart_max_markers+l:index0)
            break
        endif
        let l:type = strpart(result.text, 0, 1)
        if has_key(s:markerdata, l:type) && s:markerdata[l:type].marker != ''
            " file markers
            if !s:dart_show_in_file == 0
                if !has_key(s:markerdata[l:type], 'matchstr')
                    let s:markerdata[l:type].matchstr = '\%('
                else
                    let s:markerdata[l:type].matchstr .= '\|'
                endif
                let s:markerdata[l:type].matchstr .= '\%'.result.lnum.'l\%'.result.col.'c'
            endif
            " gutter markers
            if !s:dart_show_in_gutter == 0
                execute ":sign place ".index." name=".s:markerdata[l:type].name
                            \ . " line=".result.lnum." file=".expand("%:p")
                let s:signids += [l:index]
            endif
            let l:index += 1
        endif
    endfor

    " in file?
    if !s:dart_show_in_file == 0
        for l:val in values(s:markerdata)
            if l:val.marker != '' && has_key(l:val, 'matchstr')
                let l:val.matchid = matchadd(l:val.name, l:val.matchstr.'\)')
            endif
        endfor
    endif
endfunction  " }}}

function! s:UnplaceMarkers()  " {{{
    " gutter markers
    if exists('s:signids')
        for i in s:signids
            execute ":sign unplace ".i
        endfor
        unlet s:signids
    endif
    " file markers
    for l:val in values(s:markerdata)
        if has_key(l:val, 'matchid')
            call matchdelete(l:val.matchid)
            unlet l:val.matchid
            unlet l:val.matchstr
        endif
    endfor
endfunction  " }}}

"" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
