" Vim syntax file
" Language:	JSON
" Maintainer:	Jeroen Ruigrok van der Werven <asmodai@in-nomine.org>
" Last Change:	2009-06-16
" Version:      0.4
" {{{1

" Syntax setup {{{2
" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded

if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'json'
endif

" Syntax: Strings {{{2
syn region  jsonString    start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=jsonEscape
" Syntax: JSON does not allow strings with single quotes, unlike JavaScript.
syn region  jsonStringSQ  start=+'+  skip=+\\\\\|\\"+  end=+'+

" Syntax: Escape sequences {{{3
syn match   jsonEscape    "\\["\\/bfnrt]" contained
syn match   jsonEscape    "\\u\x\{4}" contained

" Syntax: Strings should always be enclosed with quotes.
syn match   jsonNoQuotes  "\<\a\+\>"

" Syntax: Numbers {{{2
syn match   jsonNumber    "-\=\<\%(0\|[1-9]\d*\)\%(\.\d\+\)\=\%([eE][-+]\=\d\+\)\=\>"

" Syntax: An integer part of 0 followed by other digits is not allowed.
syn match   jsonNumError  "-\=\<0\d\.\d*\>"


" Syntax: Boolean {{{2
syn keyword jsonBoolean   true false True False

" Syntax: Null {{{2
syn keyword jsonNull      null None owner devlead schedule source destination xforms remote_ops
syn keyword jsonNull      db host ops box file directory wait required on_error until time
syn keyword jsonNull      input output type name format header sep quote qforce
syn keyword jsonNull      framediff slateupload chromefilter cr_images dotzero randomfile
syn keyword jsonNull      grap cr_mastercard xmlscrub fusionpics dashboard bunzip2 XML
syn keyword jsonNull      pgpinspect encryptpics studentpics keymaint testconnect zzz
syn keyword jsonNull      allowed_environments password frequency comment
syn keyword jsonNull      cleanup gpg s3 sharefile empty debug timeout
syn keyword jsonNull      curl first second output1 output2 rerun_ok




" Syntax: Braces {{{2
syn match   jsonBraces	   "[{}\[\]]"

" Syntax: IJKL extensions
syn match   ijklComment   "#.*$"



"
" Define the default highlighting. {{{1
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_json_syn_inits")
  if version < 508
    let did_json_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  HiLink ijklComment            Comment


  HiLink jsonString             Identifier
  HiLink jsonEscape             Special
  HiLink jsonNumber		Number
  HiLink jsonBraces		Operator
  HiLink jsonNull		Function
  HiLink jsonBoolean		Boolean

  HiLink jsonNumError           Error
  HiLink jsonStringSQ           Error
  HiLink jsonNoQuotes           Error
  delcommand HiLink
endif

let b:current_syntax = "json"
if main_syntax == 'json'
  unlet main_syntax
endif

" Vim settings {{{2
" vim: ts=4 fdm=marker
"
