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

let s:save_cpoptions = &cpoptions
set cpoptions&vim




" Constants {{{1

let s:TRUE = 1
let s:FALSE = !s:TRUE
let s:PLUGIN_NAME = expand('<sfile>:t:r')

lockvar! s:TRUE s:FALSE s:PLUGIN_NAME




" Variables {{{1

let s:brainfvck = {}

" Preparation of initialization. {{{2

function! s:brainfvck.__init__() " {{{3
  call self.__init_variables__()
  call self.__init_aliases__()
endfunction

function! s:brainfvck.__init_variables__() " {{{3
  let self._variables_ = {
        \  'source': '',
        \  'instruction_pointer': 0,
        \  'buffer': repeat([0], g:brainfvck#initial_buffer_size),
        \  'data_pointer': 0,
        \  'source_size': 0
        \ }
endfunction

function! s:brainfvck.__init_aliases__() " {{{3
  call extend(self,
        \ {
        \  '>': self.increment_pointer,
        \  '<': self.decrement_pointer,
        \  '+': self.increment_byte,
        \  '-': self.decrement_byte,
        \  '.': self.output_byte,
        \  ',': self.input_byte,
        \  '[': self.begin_while,
        \  ']': self.end_while,
        \  'V': self._variables_
        \ })
endfunction




" Interface {{{1

function! brainfvck#run(source) " {{{2
  let interp = s:brainfvck.setup(a:source)
  try
    while interp.finished_p() == s:FALSE
      call interp.execute_command()
    endwhile
  catch /^brainfvck:/
    throw v:exception
  endtry
endfunction




" Core {{{1

function! s:brainfvck.increment_pointer()  " {{{2
  if self.V.data_pointer >= len(self.V.buffer) - 1
    call self.extend_buffer()
  endif
  let self.V.data_pointer += 1
  let self.V.instruction_pointer += 1
endfunction


function! s:brainfvck.decrement_pointer()  " {{{2
  if self.V.data_pointer <= 0
    throw s:create_error_message('Data pointer is a negative number.')
  endif
  let self.V.data_pointer -= 1
  let self.V.instruction_pointer += 1
endfunction


function! s:brainfvck.increment_byte()  " {{{2
  let self.V.buffer[self.V.data_pointer] += 1
  let self.V.instruction_pointer += 1
endfunction


function! s:brainfvck.decrement_byte()  " {{{2
  let self.V.buffer[self.V.data_pointer] -= 1
  let self.V.instruction_pointer += 1
endfunction


function! s:brainfvck.output_byte()  " {{{2
  echon nr2char(self.get_current_byte())
  let self.V.instruction_pointer += 1
endfunction


function! s:brainfvck.input_byte()  " {{{2
  echon 'Please input 1-byte character:'
  let byte = getchar()
  redraw!
  if type(byte) != type(0)
    throw s:create_error_message('Input value is not 1-byte character.')
  endif
  let self.V.buffer[self.V.data_pointer] = byte
  let self.V.instruction_pointer += 1
endfunction


function! s:brainfvck.begin_while()  " {{{2
  if self.get_current_byte() != 0
    let self.V.instruction_pointer += 1
    return
  endif

  let nest_level = 1
  let move_count = 0
  let after_commands = split(self.V.source[self.V.instruction_pointer + 1:], '\zs')
  for c in after_commands
    let move_count += 1
    if c == '['
      let nest_level += 1
    elseif c == ']'
      let nest_level -= 1
      if nest_level == 0
        break
      endif
    endif
  endfor

  if nest_level != 0
    throw s:create_error_message('Corresponding "]" is not found.')
  endif
  let self.V.instruction_pointer += move_count + 1
endfunction


function! s:brainfvck.end_while()  " {{{2
  if self.get_current_byte() == 0
    let self.V.instruction_pointer += 1
    return
  endif

  let nest_level = 1
  let move_count = 0
  let before_commands = reverse(split(self.V.source[:self.V.instruction_pointer - 1], '\zs'))
  for c in before_commands
    let move_count += 1
    if c == ']'
      let nest_level += 1
    elseif c == '['
      let nest_level -= 1
      if nest_level == 0
        break
      endif
    endif
  endfor

  if nest_level != 0
    throw s:create_error_message('Corresponding "[" is not found.')
  endif
  let self.V.instruction_pointer -= move_count
endfunction


function! s:brainfvck.setup(source) " {{{2
  let interp = deepcopy(self)
  let interp.V.source = interp.remove_valid_commands(a:source)
  let interp.V.source_size = strchars(interp.V.source)
  return interp
endfunction


function! s:brainfvck.finished_p() " {{{2
  return self.V.instruction_pointer >= self.V.source_size
endfunction


function! s:brainfvck.execute_command() " {{{2
  let src = self.V.source
  let command = src[self.V.instruction_pointer]
  call self[command]()
endfunction




" Misc {{{1

function! s:create_error_message(message) " {{{2
  return printf('%s: %s', s:PLUGIN_NAME, a:message)
endfunction


function! s:brainfvck.get_current_byte() " {{{2
  return self.V.buffer[self.V.data_pointer]
endfunction


function! s:brainfvck.extend_buffer() " {{{2
  call extend(self.V.buffer, repeat([0], len(self.V.buffer)))
endfunction


function! s:brainfvck.remove_valid_commands(source) " {{{2
  return substitute(a:source, '[^<>+\-,.[\]]', '', 'g')
endfunction




" Init {{{1

call s:brainfvck.__init__()




" Epilogue {{{1

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions




" __End__ {{{1
" vim: et ts=2 sts=2 sw=2 fen foldmethod=marker:
