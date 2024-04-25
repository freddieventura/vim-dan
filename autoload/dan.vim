vim9script
# freddieventura
# File with some funtions to use on vim-dan
# main.docudan
# Set it to refresh tags and highlighted notes such as
# noremap <F5> :call dan#Refreshloclist()<CR>:silent! ctags -R ./ 2>/dev/null<CR>

var VIMDAN_DIR = "/home/fakuve/baul-documents/vim-dan"

# Close tab of the loclist that belongs to currentBuffer
export def Closeloclist()
    var currentBufname = bufname('%')
    var currTab = tabpagenr()
    var winInfoList = getwininfo()

    for winInfo in winInfoList
        if ( winInfo.loclist == 1 )
            ## Extracting filename from quickfix_title
            var loclistFilename = matchstr(winInfo.variables.quickfix_title, '[^.[:space:]]\+\.[^.[:space:]]\+$')
            if (loclistFilename == currentBufname)
                exec ":" .. winInfo.tabnr .. " tabnext"
                q!
            endif
        endif
    endfor
    exec ":" .. currTab .. " tabnext"
enddef
# -----------------------------------------------


# Creating a highlighted lines location list
export def Newloclist()
    # Setting so that qfList opens up in a new tab
    # And when using it it will change the previous buffer
	set switchbuf+=usetab,newtab

	# Creating the qfList
    lvimgrep! / (X)$/ %
enddef
# -----------------------------------------------

# Customizing the location list to not to show line numbers
# -----------------------------------------------
export def Customloclist()
    var locIdRef = getloclist(0, {'id': 0}).id

    def LocFormating(info: dict<any>): list<any>
        var items = getloclist(0, {'id': info.id, 'items': 1}).items
        var l = []
        for idx in range(info.start_idx - 1, info.end_idx - 1)
          call add(l, items[idx].text)
        endfor
        return l
    enddef

    setloclist(0, [], 'r', {
        id: locIdRef,
        quickfixtextfunc: LocFormating,
    })
enddef
# -----------------------------------------------

# Opening the location list in a new tab maintaining the syntax highlighting
# -----------------------------------------------
export def Openloclist()
    # Saving current Tab we are in
    var currTab = tabpagenr()

	# Saving the current filetype
    var myFiletype = &filetype

    # Opening qfList in a new tab 
    tab lopen
    # Inserting the current filetype into the qfList
    execute 'set ft=' .. myFiletype
    set foldmethod=manual
    set foldcolumn=0

    # Concealing (X)
    execute 'syn match danX "(X)" conceal'

    # Returning to the previous tab
    exec ":" .. currTab .. " tabnext"
enddef
# -----------------------------------------------

# Refreshing the highlighted lines location list
# -----------------------------------------------
export def Refreshloclist()
    Closeloclist()
    Newloclist()
    Customloclist()
    Openloclist()
enddef
# -----------------------------------------------


# Updating tags for the current opened vim-dan main file
# -----------------------------------------------
#  We need to direct ctags to the right file within the right
#  documentation dir
export def UpdateTags()
    # Trimming dan.vim , out of filename
    var DOCU_NAME = matchstr(expand('%'), '\(main\.\)\@<=.*\(dan\)\@=')

    # Equivalent to :silent! !ctags ${VIMDAN_DIR}/${DOCU_NAME}/main.${DOCU_NAME}.dan -f ${VIMDAN_DIR}/${DOCU_NAME}/tags  2>/dev/null
    execute 'silent! !ctags ' .. VIMDAN_DIR .. '/' .. DOCU_NAME .. '/main.' .. DOCU_NAME .. 'dan -f ' .. VIMDAN_DIR .. '/' .. DOCU_NAME .. 'tags 2>/dev/null'
enddef
# -----------------------------------------------
