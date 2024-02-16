" Author: freddieventura
" File related to vim-dan linking rules
" so in files with the extension .${framework_name}dan
"      Upon locating in certain navigation areas
"      You can press Ctrl + ] and move around topics/signatures/etc
" Check https://github.com/freddieventura/vim-dan for more info

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
