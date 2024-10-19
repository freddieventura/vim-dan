vim9script
# Author: freddieventura
# File related to vim-dan linking rules
# so in files with the extension .${framework_name}dan
#      Upon locating in certain navigation areas
#      You can press Ctrl + ] and move around topics/signatures/etc
# Check https://github.com/freddieventura/vim-dan for more info

# Setting iskeyword to
set iskeyword=!-~,^*,^\|,^\",192-255

# New linkto functionality
# In vim-dan documents there are a bunch of
#   - & @link_from@ link_string &
#  That refer to
#   - # link_to # 
#  (been link_from and link_to the same)
#  You just need to locate the cursor on top of the line
#   with the linkFrom and press Ctrl + ]
#
#   The syntax is conealing @link_from@ from the user so it can only see
#   link_string
#   Basically link_from is now a unique identifier

command! GotoLinkto call GotoLinktoFn()
command! IsLineLinkto call IsLineLinktoFn()
nnoremap <expr> <C-]>  IsLineLinktoFn() ? ':GotoLinkto<CR>' :  '<C-]>'

def IsLineLinktoFn(): number
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
    if match(myString, '@.*@') != -1
        execute "tag " .. matchstr(myString, '@\@<=.*@\@=')
    else
    endif
enddef


# VIM-DAN FUNCTIONALITIES
# ----------------------------------
nnoremap <C-p> :normal $a (X)<Esc>

noremap <F4> :ToggleXConceal<CR>

noremap <F5> :call dan#Refreshloclist()<CR>:call dan#UpdateTags()<CR>:redraw!<CR>:silent! tag<CR>

command! ToggleXConceal call dan#ToggleXConceal(g:xConceal)
# ----------------------------------
#eof eof eof eof eof VIM-DAN FUNCTIONALITIES

