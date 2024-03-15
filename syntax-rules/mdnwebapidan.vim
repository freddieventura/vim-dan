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
syn region danLinkfromEntry start="&" end="&" contains=danLinkfromAmper,danLinkFromParentName,danX oneline

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
syn match danMethodLink "-   [A-Za-z_]*\w\+\.[A-Za-z_]*\w\+(.*$"hs=s+4 contains=danX,danLinktoHash
syn match danProperty "\([A-Za-z_\[\]]*\w\+\.\)\+[A-Za-z_\[\]]\+\w\+.*$" contains=danX,danLinktoHash
syn match danMethod "\([A-Za-z_\[\]]*\w\+\.\)*[A-Za-z_\[\]]*\w\+(.*$" contains=danX,danLinktoHash
hi def link danMethodLink	Identifier
hi def link danMethod Identifier
hi def link danProperty Statement


" Lists
syn match danListMarker "\%(\t\| \{0,4\}\)[-*+]\%(\s\+\S\)\@=" contains=danMethodLink
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

syn match danMykeyword "^See also\%(\s(X)\)\{,1}$" contains=danX
hi def link danMykeyword Question

syn match danMykeyword "^Examples\%(\s(X)\)\{,1}$" contains=danX
hi def link danMykeyword Question

syn match danMykeyword "^Specifications\%(\s(X)\)\{,1}$" contains=danX
hi def link danMykeyword Question

syn match danMykeyword "^Syntax\%(\s(X)\)\{,1}$" contains=danX
hi def link danMykeyword Question

syn match danMykeyword "^Formal syntax\%(\s(X)\)\{,1}$" contains=danX
hi def link danMykeyword Question

syn match danMykeyword "^Description\%(\s(X)\)\{,1}$" contains=danX
hi def link danMykeyword Question

syn match danParameters "^Parameters\%(\s(X)\)\{,1}$" contains=danX
hi def link danParameters Comment

syn match danAttributes "^Attributes\%(\s(X)\)\{,1}$" contains=danX
hi def link danAttributes CursorLine 

syn match danUsagenot "^Usage notes\%(\s(X)\)\{,1}$" contains=danX
hi def link danUsagenot Underlined

syn match danDirectives "^Directives\%(\s(X)\)\{,1}$" contains=danX
hi def link danDirectives Underlined

syn match danTechsum "^Technical summary\%(\s(X)\)\{,1}$" contains=danX
hi def link danTechsum Underlined

syn match danReturnval "^Return value\%(\s(X)\)\{,1}$" contains=danX
hi def link danReturnval Underlined

syn match danExceptions "^Exceptions\%(\s(X)\)\{,1}$" contains=danX
hi def link danExceptions WarningMsg

syn match danInstanceProp "^Instance properties\%(\s(X)\)\{,1}$" contains=danX
hi def link danInstanceProp CursorLine

syn match danInstanceMeth "^Instance methods\%(\s(X)\)\{,1}$" contains=danX
hi def link danInstanceMeth CursorLine

syn match danConstructor "^Constructor\%(\s(X)\)\{,1}$" contains=danX
hi def link danConstructor WarningMsg 

syn match danEvents "^Events\%(\s(X)\)\{,1}$" contains=danX
hi def link danEvents Special

syn match danValues "^Values\%(\s(X)\)\{,1}$" contains=danX
hi def link danValues TabLine

syn keyword danMykeyword Optional 
hi def link danMykeyword Question

syn keyword danExperimental Experimental
hi def link danExperimental Comment

syn keyword danNonstand Non-standard
hi def link danNonstand Comment

syn keyword danDeprecated Deprecated
hi def link danDeprecated WarningMsg
" Question , Nontext , LineNr , WarningMsg , Colorcolumn
" ---------------------------------------------------------
" EOF EOF EOF EOF KEYWORDS


" EMBEDDING CODE
" ---------------------------------------------------------
"  If there is some code of a certain programming language
"  embedded in the docu
"" JS Code
syn include @danJavaScript syntax/javascript.vim
unlet b:current_syntax

syn region JavaScript start=/^js$\n\n^\s\{4,}\S/ms=s+5 keepend end=/\S$\n\n\S/me=s-1 contains=@danJavaScript

"" CSS Code
syn include @danCss syntax/css.vim
unlet b:current_syntax

syn region Css start=/^css$\n\n^\s\{4,}\S/ms=s+5 keepend end=/\S$\n\n\S/me=s-1 contains=@danCss

"" HTML Code
syn include @danHtml syntax/html.vim
unlet b:current_syntax

syn region Html start=/^html$\n\n^\s\{4,}\S/ms=s+5 keepend end=/\S$\n\n\S/me=s-1 contains=@danHtml

"" JSON Code
syn include @danJson syntax/json.vim
unlet b:current_syntax

syn region Json start=/^json$\n\n^\s\{4,}\S/ms=s+5 keepend end=/\S$\n\n\S/me=s-1 contains=@danJson

" EOF EOF EOF EMBEDDING CODE
" ---------------------------------------------------------
