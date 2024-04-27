vim9script
# Author: freddieventura
# File related to vim-dan linking rules
# so in files with the extension .${framework_name}dan
#      Upon locating in certain navigation areas
#      You can press Ctrl + ] and move around topics/signatures/etc
# Check https://github.com/freddieventura/vim-dan for more info
# 
# This is an snippet to start file-specific linking rules
# Use this snippet as a template for defining file-specific linking rules
#
# In order to customize the file follow this instructions
#       - Name it ${framework_name}.dan
#       - Place it in vim-dan/linking-rules/
#       - Peform the following Substitution :44,$s/Spec/${framework_name}/g
#       - Modify only two lines in the following document 
#           - matchingPatternList
#               This corresponds to the patterns that recognises that there is 
#               a link in that line.
#           - trimPatternList
#               Out of the previous line match , the pattern that will be
#               trimmed out of the string, after this trimming the resulting
#               string will be searched as a tag
#
# For instance if you want to match lines like the following ones
#    - somethingSomething(pepe)
#    - someotherstuff(luis)
# matchingPatternList will recognise the whitespaces , the dash , the
# whitespace and the rest of the string till the line break
#    var matchingPatternList = ['\s*-\s\+.*$']
# trimPatternList will recognise that whitespaces , that dash and the first
# whitespace
#    var trimPatternList = ['\s*-\s\+', '\s(X)']
#    (remember we add '\s(X)' to skip the pattern of our highlighted lines on documentation

# Setting iskeyword to
set iskeyword=!-~,^*,^\|,^\",192-255

# Understanding Linkto functionality
# In vim-dan documents there are a bunch of
#   - & link from &
#  That refer to
#   - # link to # 
#  (been link from and link to the same)
#  You just need to locate the cursor on top of the line
#   with the linkFrom and press Ctrl + ]
command! GotoLinkto call GotoLinktoFn()
command! IsLineLinkto call IsLineLinktoFn()
command! GotoNodejsLinkto call GotoNodejsLinktoFn()
command! IsLineNodejsLinkto call IsLineNodejsLinktoFn()
nnoremap <expr> <C-]> ( IsLineLinktoFn() ? ':GotoLinkto<CR>' : ( IsLineNodejsLinktoFn() ? ':GotoNodejsLinkto<CR>' : '<C-]>'))


def! IsLineLinktoFn(): number
    # if there is a $linkto& in the current line
    if match(getline('.'), '&.*&') != -1
        return 1
    else
    endif
    return 0
enddef

def GotoLinktoFn(): void
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

def IsLineNodejsLinktoFn(): number
    # Matching at least one pattern of the list
    # MODIFY LINE BELOW MODIFY LINE BELOW !!
    var matchingPatternList = ['\s*-\s\+.*$']
    for patternI in matchingPatternList
        if match(getline('.'), patternI) != -1
            return 1
        endif
    endfor
    return 0
enddef

def GotoNodejsLinktoFn(): void
    var myString = getline('.')

    # Chopping string from patternList elements
    # MODIFY LINE BELOW MODIFY LINE BELOW !!
    var trimPatternList = ['\s*-\s\+', '\s(X)']
    for patternI in trimPatternList
        if match(myString, patternI) != -1
            myString = substitute(myString, patternI, '', '')
        endif
    endfor

    execute "tag " .. myString
enddef


# VIM-DAN FUNCTIONALITIES
# ----------------------------------
nnoremap <C-p> :normal $a (X)<Esc>

noremap <F4> :ToggleXConceal<CR>

noremap <F5> :call dan#Refreshloclist()<CR>:call dan#UpdateTags()<CR>:redraw!<CR>:silent! tag<CR>

command! ToggleXConceal call dan#ToggleXConceal(g:xConceal)
# ----------------------------------
#eof eof eof eof eof VIM-DAN FUNCTIONALITIES
