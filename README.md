# Fork notice

While technically a fork of [dart-vim-plugin][] this fork draws heavily on the
excellent [vim-flake8][] plugin for python.


# Dart plugin for VIM

This is an (unsupported) plugin for using Dart with Vim. Pull requests welcome!

Looking for an IDE experience? Try [Dart Editor][1],
[Dart plugin for Eclipse][2], or [Dart plugin for IntelliJ/WebStorm][3].


## Prerequisites

You need to install [pathogen][] in order to install and use dart-vim-plugin.
Pathogen makes it super easy to install plugins and runtime files under
`~./vim/bundle` or in their own private directories.

You need [dartanalyzer][] to enable static code analysis.

## Installation

1. Make a directory.

        mkdir -p ~/.vim/bundle


2. Clone a repository.

        cd ~/.vim/bundle
        git clone https://github.com/dart-lang/dart-vim-plugin


3. Put following codes in your `~/.vimrc`.

        if has('vim_starting')
          set nocompatible
          set runtimepath+=~/.vim/bundle/dart-vim-plugin
        endif
        filetype plugin indent on


## Usage

1. Open a dart file
2. Press `<F7>` to run `dartanalyzer` on it

It shows the errors inside a quickfix window, which will allow your to quickly
jump to the error locations by simply pressing [Enter].

If any of `g:dart_show_in_gutter` or `g:dart_show_in_file` are set to 1, call:

    call dart#DartUnplaceMarkers()

To remove all markers. No default mapping is provided.


## Customization

If you don't want to use the `<F7>` key for dart checking, simply remap it to
another key.  It autodetects whether it has been remapped and won't register
the `<F7>` key if so.  For example, to remap it to `<F3>` instead, use:

    autocmd FileType dart map <buffer> <F3> :call dart#DartAnalyzer()<CR>

To customize the location of quick fix window, set `g:dart_quickfix_location`:

    let g:dart_quickfix_location="topleft"

To customize whether the quickfix window opens, set `g:dart_show_quickfix`:

    let g:dart_show_quickfix=0  " don't show
    let g:dart_show_quickfix=1  " show (default)

To customize whether the show signs in the gutter, set `g:dart_show_in_gutter`:

    let g:dart_show_in_gutter=0  " don't show (default)
    let g:dart_show_in_gutter=1  " show


To customize whether the show marks in the file, set `g:dart_show_in_file`:

    let g:dart_show_in_file=0  " don't show (default)
    let g:dart_show_in_file=1  " show

To customize the number of marks to show, set `g:dart_max_markers`:

    let g:dart_max_markers=500  " (default)

To customize the gutter markers, set any of `dart_error_marker`, `dart_warning_marker`.
Setting one to the empty string disables it. Ex.:

    let g:dart_error_marker='EE'     " set error marker to 'EE'
    let g:dart_warning_marker='WW'   " set warning marker to 'WW'

To customize the colors used for markers, define the highlight groups, `Dart_Error`,
`Dart_Warning`:

    " to use colors defined in the colorscheme
    highlight link Flake8_Error      Error
    highlight link Flake8_Warning    WarningMsg

To customize the location of your dartanalyzer binary, set `g:dart_analyzer_cmd=`:

    let g:dart_analyzer_cmd="/usr/lib/dart/bin/dartanalyzer"

To customize the location of your dart sdk, set `g:dart_analyzer_sdk`:

    let g:dart_analyzer_sdk="/usr/lib/dart"

To customize the location of your dart packages, set `g:dart_analyzer_package_root`:

    let g:dart_analyzer_package_root=""  " (default)
    let g:dart_analyzer_package_root="/path/to/packages"


## Tips
A tip might be to run the dart check every time you write a dart file, to
enable this, add the following line to your `.vimrc` file (thanks
[Godefroid](http://github.com/gotcha)!):

    autocmd BufWritePost *.py call dart#DartAnalyzer()


## License

    Copyright 2012, the Dart project authors. All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are
    met:
        * Redistributions of source code must retain the above copyright
          notice, this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above
          copyright notice, this list of conditions and the following
          disclaimer in the documentation and/or other materials provided
          with the distribution.
        * Neither the name of Google Inc. nor the names of its
          contributors may be used to endorse or promote products derived
          from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[1]: http://www.dartlang.org/editor
[2]: http://news.dartlang.org/2012/08/dart-plugin-for-eclipse-is-ready-for.html
[3]: http://plugins.intellij.net/plugin/?id=6351
[dartanalyzer]: https://www.dartlang.org/tools/analyzer/
[dart-vim-plugin]: https://github.com/dart-lang/dart-vim-plugin
[pathogen]: https://github.com/tpope/vim-pathogen
[vim-flake8]: https://github.com/nvie/vim-flake8
