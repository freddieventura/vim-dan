" Vim syntax file
" usage: nodejsdan (for nodejsdan) , made for documentation parsed from node.js page
" Current Maintainer: freddieventura (https://github.com/freddieventura)
" Last Change:	2024 Jan 19 

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

if has("folding")
    setlocal foldmethod=marker
    set foldcolumn=3
endif


" Link to tags
if has("conceal")
  setlocal cole=2 cocu=nc
endif

if has("ebcdic")
  syn match nodejsdanHyperTextJump	"<[^"*|]\+>" contains=nodejsdanLeftBracket,nodejsdanRightBracket
else
  syn match nodejsdanHyperTextJump	"<[#-)!+-~]\+>" contains=nodejsdanLeftBracket,nodejsdanRightBracket
endif
if has("conceal")
  syn match nodejsdanLeftBracket		contained "<" conceal
  syn match nodejsdanRightBracket    contained ">" conceal
else
  syn match nodejsdanLeftBracket		contained "<"
  syn match nodejsdanRightBracket    contained ">" 
endif

syn match nodejsdanMethodLink "-   [A-Za-z_]*\w\+\.[A-Za-z_]*\w\+(.*$"hs=s+4 contains=nodejsdanXonline,nodejsdanKonline
syn match nodejsdanXonline "(X)"
syn match nodejsdanKonline "(K)"

hi def link nodejsdanHyperTextJump	Identifier
hi def link nodejsdanMethodLink	Identifier
ei def link nodejsdanLeftBracket		Ignore
hi def link nodejsdanRightBracket    Ignore
hi def link nodejsdanXonline StatusLineTerm
hi def link nodejsdanKonline SpellRare


" Some keywords
syn keyword nodejsdanHistory History
syn match nodejsdanStability "Stability: \d"
syn match nodejsdanAdded "Added in: v\d.*"
syn match nodejsdanEvent "Event:\s"he=e-1
syn match nodejsdanExtends "Extends:\s"he=e-1

"syn cluster nodejsdanKeyword contains=nodejsdanStability,nodejsdanHistory,nodejsdanAdded

hi def link nodejsdanHistory Type
hi def link nodejsdanStability Type
hi def link nodejsdanAdded Type
hi def link nodejsdanEvent PreProc
hi def link nodejsdanExtends Comment


" Linked items
syn match nodejsdanClassEntry "^Class: .*"he=e-1 contains=nodejsdanHash
syn match nodejsdanMethodEntry "^[A-Za-z_]*\w\+\.[A-Za-z_]*\w\+(.*#"he=e-1 contains=nodejsdanHash
"syn match nodejsdanHyperTextEntry "@\w\+\n"he=e-1 contains=nodejsdanAt
syn match nodejsdanHash  contained "#" conceal

hi def link nodejsdanHash    Ignore
hi def link nodejsdanClassEntry String
hi def link nodejsdanMethodEntry String

" List
syn match nodejsdanListMarker "\%(\t\| \{0,4\}\)[-*+]\%(\s\+\S\)\@=" contains=nodejsdanMethodLink
hi def link nodejsdanListMarker Statement


" JS Code
syn include @nodejsdanJavaScript syntax/javascript.vim
unlet b:current_syntax

syn region javaScript start=/[\.:]$\n\n\s\{4}/ms=s+5 end=/.$\n\n^\S/me=e-4 contains=@nodejsdanJavaScript
