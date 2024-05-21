" Vim syntax file
" Current Maintainer: freddieventura (https://github.com/freddieventura)
" Syntax referred to vim-dan Documents 
" More info https://github.com/freddieventura/vim-dan

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
syn region danLinkfromEntry start="&" end="&" contains=danLinkfromAmper,danLinkFromParentName oneline

if has("conceal")
  syn match danLinkfromAmper contained "&" conceal
  syn match danLinkFromParentName contained "@[-./[:alnum:]_~]*@" conceal
else
  syn match danLinkfromAmper contained "&"
  syn match danLinkFromParentName contained "@[-./[:alnum:]_~]*@"
endif


hi def link danLinkfromEntry Identifier
hi def link danLinkFromAmper Ignore
hi def link danLinkFromParentName Ignore

" Links to
syn match danLinktoEntry "^#\s.*\s#$" contains=danLinktoHash
syn match danLinktoEntryXed "^#\s.*\s#\%(\s(X)\)\{,1}$" contains=danLinktoHash,danX
syn match danLinktoHash contained "#" conceal

hi def link danLinktoHash Ignore
hi def link danLinktoEntry String
hi def link danLinktoEntryXed String

" (X) Annotation
syn match danX "(X)"

hi def link danX StatusLineTerm

" Method links
syn match danProperty "[A-Za-z][A-Za-z0-9\_\$]*\.[A-Za-z][A-Za-z0-9\_\$]*\(\s\|\n\|#\)" contains=danX,danLinktoHash
syn match danMethod "[A-Za-z][A-Za-z0-9\_\$]*\.[A-Za-z][A-Za-z0-9\_\$]*(.*)#\{,1}" contains=danX,danLinktoHash
hi def link danMethodLink	Identifier
hi def link danMethod Identifier
hi def link danProperty Statement


" Lists
syn match danListMarker "\%(\t\| \{0,4\}\)[-*+]\%(\s\+\S\)\@=" contains=danMethod,danProperty,danEvent,danClass
hi def link danListMarker Statement
" ---------------------------------------------------------
" EOF EOF EOF EOF BASIC DAN SYNTAX ITEMS


" KEYWORDS
" ---------------------------------------------------------
"  Repeated keywords for the docu
"  Check for Newline starting words ocurrence with
"  cat main.${framework}dan | grep -o -E '^\w+' | sort | uniq -c | sort -nr

"syn match danMykeyword 

"hi def link danMykeyword Question

syn match danResponses "^Responses\%(\s(X)\)\{,1}$" contains=danX
hi def link danResponses Underlined

syn match danParameters "^Parameters\%(\s(X)\)\{,1}$" contains=danX
hi def link danParameters CursorLineNr

syn match danReferences "^References\%(\s(X)\)\{,1}$" contains=danX
hi def link danReferences Question

syn match danOtherInfo "^Other Info\%(\s(X)\)\{,1}$" contains=danX
hi def link danOtherInfo TabLine

syn match danSummary "^Summary\%(\s(X)\)\{,1}$" contains=danX
hi def link danSummary TabLine

syn match danCode "^Code\%(\s(X)\)\{,1}$" contains=danX
hi def link danCode TabLine

syn match danLatestCode "^Latest Code\%(\s(X)\)\{,1}$" contains=danX
hi def link danLatestCode TabLine

syn match danSeeAlso "^See Also\%(\s(X)\)\{,1}$" contains=danX
hi def link danSeeAlso TabLine

syn match danCodeSamples "^  Code Samples\%(\s(X)\)\{,1}$" contains=danX
hi def link danCodeSamples Question

syn match danExampleResponses "^  Example Responses\%(\s(X)\)\{,1}$" contains=danX
hi def link danExampleResponses TabLine

"syn match danValues "^Values\%(\s(X)\)\{,1}$" contains=danX
"hi def link danValues TabLine

" Under normal colour scheme 
" term=                                             ,  Bold       ,underline 
" ctermfg= Green     , DarkBlue , DarkYellow, Red   ,  White      ,darkmagenta
" ctermbg=                                          ,  Darkgray    , 
"           Question , Nontext , LineNr , WarningMsg , Colorcolumn,Underlined
"            Type
" term=                                    , bold               , underline
" ctermfg=  darkmagenta,  blue ,  cyan     ,         ,Darkyellow, 
" ctermbg=
"           PreProc ,  Comment , Identifier, Ignore , Statement, CursorLine
" term=     Darkmagenta , Bold
" ctermfg= 
" ctermbg=  underline  , Lightgray
"           Underlined, StatusLine. 
" ---------------------------------------------------------
" EOF EOF EOF EOF KEYWORDS


" EMBEDDING CODE
" ---------------------------------------------------------
"  If there is some code of a certain programming language
"  embedded in the docu
" PROGRAMMING LANGUAGE Code
syn include @danBash syntax/bash.vim
unlet b:current_syntax

syn region bash start=/^  Code Samples$\n\n\s\{4}/ms=s+5 keepend end=/.$\n\n^\S/me=e-4 contains=@danBash
" EOF EOF EOF EMBEDDING CODE
" ---------------------------------------------------------
