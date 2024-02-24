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
