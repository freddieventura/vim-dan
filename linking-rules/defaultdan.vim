" Author: freddieventura
" File related to vim-dan linking rules
" so in files with the extension .${framework_name}dan
"      Upon locating in certain navigation areas
"      You can press Ctrl + ] and move around topics/signatures/etc
" Check https://github.com/freddieventura/vim-dan for more info

" Setting iskeyword to
set iskeyword=!-~,^*,^\|,^\",192-255

" Understanding Linkto functionality
" In vim-dan documents there are a bunch of
"   - & link from &
"  That refer to
"   - # link to # 
"  (been link from and link to the same)
"  You just need to locate the cursor on top of the line
"   with the linkFrom and press Ctrl + ]
command! GotoLinkto call GotoLinktoFn()
command! IsLineLinkto call IsLineLinktoFn()
nnoremap <expr> <C-]>  IsLineLinktoFn() ? ':GotoLinkto<CR>' :  '<C-]>'

def! IsLineLinktoFn(): number
    # if there is a $linkto& in the current line
    if match(getline('.'), '&.*&') != -1
        return 1
    else
    endif
    return 0
enddef

def! GotoLinktoFn(): void
    var myString = getline('.')

    # If there is a keyword enclosed in between &keyword& goto there
    if match(myString, '&.*&') != -1
        # Some patterns to be filtered on the link_from
        # This filters out the ats at & @parentName@ linkFrom &
        var patternList = ['@\(\w*\)\@=', '@\(\w*\)\@=']
        for patternI in patternList
            if match(myString, patternI) != -1
                myString = substitute(myString, patternI, '', '')
            endif
        endfor
        execute "tag " .. matchstr(myString, '&\@<=.*&\@=')
    else
    endif
enddef
