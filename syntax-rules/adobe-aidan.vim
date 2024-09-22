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
syn match danMethodLink "-   [A-Za-z_]*\w\+\.[A-Za-z_]*\w\+(.*$"hs=s+4 contains=danXonline,danKonline,danLinktoHash
syn match danProperty "\([A-Za-z_\[\]]*\w\+\.\)\+[A-Za-z_\[\]]\+\w\+.*$" contains=danXonline,danKonline,danLinktoHash
syn match danMethod "\([A-Za-z_\[\]]*\w\+\.\)*[A-Za-z_\[\]]*\w\+(.*$" contains=danXonline,danKonline,danLinktoHash
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

syn keyword danDescription Description
syn keyword danParameters Parameters
syn keyword danParameter Parameter
syn keyword danType Type
syn keyword danReturns Returns

syn match danTopicStroke "-\{8,}"

hi def link danDescription Question
hi def link danParameters Nontext
hi def link danParameter LineNr
hi def link danType Nontext
hi def link danReturns WarningMsg
hi def link danTopicStroke ColorColumn

" ---------------------------------------------------------
" EOF EOF EOF EOF KEYWORDS


" EMBEDDING CODE
" ---------------------------------------------------------
"  If there is some code of a certain programming language
"  embedded in the docu

syn include @danJS syntax/javascript.vim
unlet b:current_syntax

syn region javaScript start=/^Example #$/ms=s+9 end=/^Previous Next$/me=e-4 contains=@danJS
" EOF EOF EOF EMBEDDING CODE
" ---------------------------------------------------------
