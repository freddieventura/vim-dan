" freddieventura
" related to nodejs.dan filetype which is valid to parse nodejs official
" documentation with ctags

" Using Ctrl + ] to access methods
command! GotoMethod call GotoMethodFn()
command! IsMethodUnderCursor call IsMethodUnderCursorFn()
nnoremap <expr> <C-]> IsMethodUnderCursorFn() ? ':GotoMethod<CR>' : '<C-]>'

def IsMethodUnderCursorFn(): number
    var myInnerWORD = expand('<cWORD>')
    var myPattern = '[A-Za-z_]*\w\+\.[A-Za-z_]*\w\+(\@='
    if match(myInnerWORD, myPattern) == -1
        return 0
    else
        return 1
    endif
enddef

def GotoMethodFn(): void
    var myInnerWORD = expand('<cWORD>')
    var myPattern = '[A-Za-z_]*\w\+\.[A-Za-z_]*\w\+(\@='
    var myMatchStr = matchstr(myInnerWORD, myPattern)
    execute "tag " .. myMatchStr 
enddef
