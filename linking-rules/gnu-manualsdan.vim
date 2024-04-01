vim9script
# Author: freddieventura
# File related to vim-dan linking rules
# so in files with the extension .${framework_name}dan
#      Upon locating in certain navigation areas
#      You can press Ctrl + ] and move around topics/signatures/etc
# Check https://github.com/freddieventura/vim-dan for more info

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
nnoremap <expr> <C-]>  IsLineLinktoFn() ? ':GotoLinkto<CR>' :  '<C-]>'

def IsLineLinktoFn(): number
    # if there is a $linkFrom& in the current line
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
        # This filters out the ampersands on & linkFrom &
    #    var patternList = ['&\s', '\s&']
    #    for patternI in patternList
    #        if match(myString, patternI) != -1
    #            myString = substitute(myString, patternI, '', '')
    #        endif
    #    endfor
        execute "tag " .. matchstr(myString, '&\@<=.*&\@=')
    else
    endif
enddef

# VIM-DAN FUNCTIONALITIES
# ----------------------------------
nnoremap <C-p> :normal $a (X)<Esc>
noremap <F4> :ToggleXConceal<CR>
noremap <F5> :call dan#Refreshloclist()<CR>:silent! !ctags -R ./ 2>/dev/null<CR>:redraw!<CR>:silent! tag<CR>

command! ToggleXConceal call ToggleXConceal(g:xConceal)

g:xConceal = 0
def ToggleXConceal(xConceal: number): void
    if (xConceal == 1)
        syn match danX "(X)"
        g:xConceal = 0
    elseif (xConceal == 0)
        syn match danX "(X)" conceal
        g:xConceal = 1
    else
        echo 'ERROR ON XConceal Toggle'
    endif
enddef
# ----------------------------------
#eof eof eof eof eof VIM-DAN FUNCTIONALITIES
