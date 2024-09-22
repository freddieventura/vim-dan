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
  syn match danLinkFromParentName contained "@\w*@" conceal
else
  syn match danLinkfromAmper contained "&"
  syn match danLinkFromParentName contained "@\w*@"
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


"syn match danValues "^Values\%(\s(X)\)\{,1}$" contains=danX

syn match danHistory "^History$"
hi def link danHistory Type

syn match danStability "^Stability: \d"
hi def link danStability Type

syn match danAdded "^Added in:.*$"
hi def link danAdded Type

syn match danEvent "Event:.*\%(\s(X)\)\{,1}$"he=s+5 contains=danX,danMethodLink,danProperty,danMethod,danLinktoHash
hi def link danEvent Underlined 

syn match danExtends "Extends:.*\%(\s(X)\)\{,1}$"he=s+7 contains=danX,danMethodLink,danProperty,danMethod
hi def link danExtends Comment

syn match danClass "Class:.*\%(\s(X)\)\{,1}$"he=s+5 contains=danX,danLinktoHash
hi def link danClass CursorLine 

syn match danReturn "Returns:.*\%(\s(X)\)\{,1}$"he=s+8 contains=danX
hi def link danReturn Underlined

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
syn include @danJavaScript syntax/javascript.vim
unlet b:current_syntax

syn region javaScript start=/[\.:]$\n\n\s\{4}/ms=s+5 keepend end=/.$\n\n^\S/me=e-4 contains=@danJavaScript
" EOF EOF EOF EMBEDDING CODE
" ---------------------------------------------------------
