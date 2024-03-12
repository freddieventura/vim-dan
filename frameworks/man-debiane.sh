#!/bin/bash

# DECLARING VARIABLES AND PROCESSING ARGS
# -------------------------------------
# (do not touch)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../scripts/helpers.sh"

DOCU_PATH="$1"
shift
DOCU_NAME=$(basename ${0} '.sh')
MAIN_TOUPDATE="${DOCU_PATH}/main-toupdate.${DOCU_NAME}dan"
DOWNLOAD_LINK="https://manpages.debian.org/contents-bookworm.html"
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS


indexing_rules(){
    echo "ERROR !!"
    echo "This documentation is not to be indexed. Refer to ./vim-dan.sh man-debian -x"
}

parsing_rules(){
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}



# Parsing our own index for docu
# -----------------------------------------------------------
# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}


mapfile -t files_array < <(find ${DOCU_PATH}/downloaded/ -type f | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')

for file in "${files_array[@]}"; do
    link_from="& $(cat ${file} | pup -i 0 --pre '.head-ltitle' | pandoc -f html -t plain) &"
    echo "- ${link_from}" >> ${MAIN_TOUPDATE}
done
# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu

# TROUBLESHOOTING
# TROUBLESHOOTING
##for file in "${files_array[@]}"; do
##    echo "$file"
##    ((count++))
##    if [ "$count" -eq 20 ]; then
##        break
##    fi
##done
# TROUBLESHOOTING
# TROUBLESHOOTING


# Parsing each manpage
# -----------------------------------------------------------
for file in "${files_array[@]}"; do

    ## Creating Link_to
    echo "# $(cat ${file} | pup -i 0 --pre '.head-ltitle' | pandoc -f html -t plain) #" >> ${MAIN_TOUPDATE} 

    cat ${file} | pup -i 0 --pre 'div.manual-text' | pandoc -f html -t plain  >> ${MAIN_TOUPDATE} 
done
# -----------------------------------------------------------

}


## PARSING ARGUMENTS
## ------------------------------------
# (do not touch)
while getopts ":ip" opt; do
    case ${opt} in
        i)
            indexing_rules
            ;;
        p)
            parsing_rules
            ;;
        h | *)
            echo "Usage: $0 [-i] [-p] [-h] "
            echo "Options:"
            echo "  -i  Indexing"
            echo "  -p  Parsing"
            echo "  -h  Help"
            exit 0
            ;;
    esac
done
## EOF EOF EOF PARSING ARGUMENTS
## ------------------------------------
