" Author: freddieventura
" File related to vim-dan linking rules
" so in files with the extension .${framework_name}dan
"      Upon locating in certain navigation areas
"      You can press Ctrl + ] and move around topics/signatures/etc
" Check https://github.com/freddieventura/vim-dan for more info

" Using Ctrl + ] to access topics
command! GotoTopic call GotoTopicFn()
command! IsLineTopic call IsLineTopicFn()
nnoremap <expr> <C-]> IsLineTopicFn() ? ':GotoTopic<CR>' : '<C-]>'

def IsLineTopicFn(): number
    # Matching at least one pattern of the list
    var patternList = ['\(^\s*\d\{,3}\.\s\+\)\@<=[0-9A-Z-a-z<>\*:]\+\(\s\w*\)*$']
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
    var patternList = ['^\s*\d\{,3}\.\s\+', '\s(X)', '\sDeprecated', '\sExperimental', '\sNon-standard']
    for patternI in patternList
        if match(myString, patternI) != -1
            myString = substitute(myString, patternI, '', '')
        endif
    endfor

    execute "tag " .. myString
enddef
