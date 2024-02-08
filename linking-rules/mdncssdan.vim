" freddieventura
" related to mdncss.dan filetype which is valid to parse mdn css documentation
" documentation with ctags

" Using Ctrl + ] to access topics
command! GotoTopic call GotoTopicFn()
command! IsLineTopic call IsLineTopicFn()
nnoremap <expr> <C-]> IsLineTopicFn() ? ':GotoTopic<CR>' : '<C-]>'

def IsLineTopicFn(): number
    # Matching at least one pattern of the list
    var patternList = ['\(\s*-\s\+\)\@<=\(\S*$\|\S*\s(\S*)\)']
    for patternI in patternList
        if match(getline('.'), patternI) != -1
            return 1
        endif
    endfor
    return 0
enddef

def GotoTopicFn(): void
    var myString = getline('.')

    # Chopping string from patternList elements
    var patternList = ['\s*-\s\+', '\s(X)', '(\S\+)', '\(\w\)\@<=\#\w*']
    for patternI in patternList
        if match(myString, patternI) != -1
            myString = substitute(myString, patternI, '', '')
        endif
    endfor

    execute "tag " .. myString
enddef
