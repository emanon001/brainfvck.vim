" Processing system of brainf*ck.
" Version: 0.0.1
" Author:  emanon001 <emanon001@gmail.com>
" License: DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE, Version 2 {{{
"     This program is free software. It comes without any warranty, to
"     the extent permitted by applicable law. You can redistribute it
"     and/or modify it under the terms of the Do What The Fuck You Want
"     To Public License, Version 2, as published by Sam Hocevar. See
"     http://sam.zoy.org/wtfpl/COPYING for more details.
" }}}

" Prologue {{{1

scriptencoding utf-8

if exists('g:loaded_brainfvck')
  finish
endif

let s:save_cpoptions = &cpoptions
set cpoptions&vim




" Options {{{1

function! s:set_default_option(name, value)
  if !exists('g:brainfvck#' . a:name)
    let g:brainfvck#{a:name} = a:value
  endif
endfunction

" Note: In practice, the size of 30,000 is required.
call s:set_default_option('initial_buffer_size', 100)




" Commands {{{1

command! -nargs=+ Brainfvck
      \ redraw! | call brainfvck#run(<q-args>)

command! -nargs=1 -complete=file BrainfvckFile
      \ redraw! | call brainfvck#run(join(readfile(expand(<q-args>)), ''))




" Epilogue {{{1

let g:loaded_brainfvck = 1

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions




" __End__ {{{1
" vim: et ts=2 sts=2 sw=2 fen foldmethod=marker:
