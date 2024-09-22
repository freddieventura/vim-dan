" Vim syntax file
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


" BASIC DAN SYNTAX ITEMS
" ---------------------------------------------------------
" Link to tags
if has("conceal")
  setlocal cole=2 cocu=nc
endif

" Links from
syn region danLinkfromEntry start="&" end="&" contains=danLinkfromAmper oneline

if has("conceal")
  syn match danLinkfromAmper contained "&" conceal
else
  syn match danLinkfromAmper contained "&"
endif


hi def link danLinkfromEntry Identifier
hi def link danLinkFromAmper Ignore

" Links to
syn match danLinktoEntry "^#\s.*\s#$" contains=danLinktoHash
syn match danLinktoEntryXed "^#\s.*\s#\s(X)$" contains=danLinktoHash
syn match danLinktoHash contained "#" conceal

hi def link danLinktoHash Ignore
hi def link danLinktoEntry String
hi def link danLinktoEntryXed String


" (X) and (K) Annotation
syn match danXonline "(X)"
syn match danKonline "(K)"

hi def link danXonline StatusLineTerm
hi def link danKonline SpellRare

" Method links
syn match danMethodLink "-   [A-Za-z_]*\w\+\.[A-Za-z_]*\w\+(.*$"hs=s+4 contains=danXonline,danKonline
hi def link danMethodLink	Identifier


" Lists
syn match danListMarker "\%(\t\| \{0,4\}\)[-*+]\%(\s\+\S\)\@=" contains=danMethodLink
hi def link danListMarker Statement
" ---------------------------------------------------------
" EOF EOF EOF EOF BASIC DAN SYNTAX ITEMS

" KEYWORDS
" ---------------------------------------------------------
"  Repeated keywords for the docu

"syn keyword danNewkey Newkey
"hi def link danNewkey Question

syn match danSince '^Since:'
hi def link danSince Question


syn match danApinote '^\s\{8}API note:'
hi def link danApinote Question

syn match danParameters '^\s\{8}Parameters:'
hi def link danParameters Question

syn match danReturns '^\s\{8}Returns:'
hi def link danReturns Question
" ---------------------------------------------------------
" EOF EOF EOF EOF KEYWORDS


" EMBEDDING CODE
" ---------------------------------------------------------
"  If there is some code of a certain programming language
"  embedded in the docu
"syn include @danJava syntax/java.vim
"unlet b:current_syntax
"
"syn region javaScript start=/\n\{3,}/ end=/^Previous Next$/me=e-4 contains=@danJava
" EOF EOF EOF EMBEDDING CODE
" ---------------------------------------------------------
