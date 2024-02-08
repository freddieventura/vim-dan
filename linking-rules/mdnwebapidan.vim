" freddieventura
" related to mdncss.dan filetype which is valid to parse mdn css documentation
" documentation with ctags

" Using Ctrl + ] to access topics
command! GotoTopic call GotoTopicFn()
command! IsLineTopic call IsLineTopicFn()
nnoremap <expr> <C-]> IsLineTopicFn() ? ':GotoTopic<CR>' : '<C-]>'

def IsLineTopicFn(): number
    var myPattern = '\(-\s\s\s\w.*\)\@<=\S\{0,2}.*$'
    if match(getline('.'), myPattern) == -1
        return 0
    else
        return 1
    endif
enddef

def GotoTopicFn(): void
    var myPattern = '\(-\s\s\s\)\@<=\S\{0,2}.*$'
    var myMatchStr = matchstr(getline('.'), myPattern)
    var myExpression = '\s(X)'
    if (match(myMatchStr, myExpression) != -1)
        myMatchStr = substitute(myMatchStr, myExpression, '', '')
    endif
    myExpression = '\sDeprecated'
    if (match(myMatchStr, myExpression) != -1)
        myMatchStr = substitute(myMatchStr, myExpression, '', '')
    endif
    myExpression = '\sNon-standard'
    if (match(myMatchStr, myExpression) != -1)
        myMatchStr = substitute(myMatchStr, myExpression, '', '')
    endif
    myExpression = '\sExperimental'
    if (match(myMatchStr, myExpression) != -1)
        myMatchStr = substitute(myMatchStr, myExpression, '', '')
    endif
   execute "tag " .. myMatchStr 
enddef