" Author: freddieventura
" File related to vim-dan linking rules
" so in files with the extension .${framework_name}dan
"      Upon locating in certain navigation areas
"      You can press Ctrl + ] and move around topics/signatures/etc
" Check https://github.com/freddieventura/vim-dan for more info

command! GotoTopic call GotoTopicFn()
command! IsLineTopic call IsLineTopicFn()
nnoremap <expr> <C-]> IsLineTopicFn() ? ':GotoTopic<CR>' : '<C-]>'

def IsLineTopicFn(): number
    # if there is a $linkto& in the current line
    if match(getline('.'), '&.*&$') != -1
        return 1
    else
        # in case other patterns in the line do match
        var patternList = ['\(-\s*\)\@<=\w.*']
        for patternI in patternList
            if match(getline('.'), patternI) != -1
                return 1
            endif
        endfor
    endif
    return 0
enddef

def GotoTopicFn(): void
    var myString = getline('.')

    # If there is a keyword enclosed in between &keyword& goto there
    if match(myString, '&.*&$') != -1
        # Some patterns to be filtered on the link_from
        # This filters out the ats at @parentName@
        var patternList = ['@\(\w*\)\@=', '@\(\w*\)\@=']
        for patternI in patternList
            if match(myString, patternI) != -1
                myString = substitute(myString, patternI, '', '')
            endif
        endfor
        execute "tag " .. matchstr(myString, '&\@<=.*&\@=')
    else
        # Some patterns to be filtered on the match
        var patternList = ['-\s*\', '\s*-\s\+', '\s(X)']
        for patternI in patternList
            if match(myString, patternI) != -1
                myString = substitute(myString, patternI, '', '')
            endif
        endfor

        execute "tag " .. myString
    endif
enddef
