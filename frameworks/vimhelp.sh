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
DOWNLOAD_LINK="git clone git@github.com:vim/vim.git"
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS


indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

    git clone ${DOWNLOAD_LINK} ${DOCU_PATH}/downloaded 
    mv ${DOCU_PATH}/downloaded/vim/runtime/doc ${DOCU_PATH}/downloaded
    rm -rf ${DOCU_PATH}/downloaded/vim 
    find ${DOCU_PATH}/downloaded/ -type f ! -name "*.txt" -delete

}

parsing_rules(){
set -x
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}

# Parsing our own index for docu
# -----------------------------------------------------------
# This will be the linkFrom items
measure_depth() { echo "${*#/}" | awk -F/ '{print NF}'; }
echo "index" | figlet >> ${MAIN_TOUPDATE}


mapfile -t files_array < <(find ${DOCU_PATH}/downloaded/ -type f -name "*" | sort)

for file in "${files_array[@]}"; do
	echo "$file"
done


for file in "${files_array[@]}"; do

    # If in need to calculate parent directory for hierarchy
    parentname="$(basename "$(dirname "$file")")"
    parentname_prev="$(basename "$(dirname "$prev_file")")"
    if [[ ${parentname} != ${parentname_prev} ]]; then
        echo "- ${parentname}" >> ${MAIN_TOUPDATE}
    fi

    link_from="& @${parentname}@ $(basename ${file})&"
    rel_nesting_level=$(($(measure_depth ${file})-$(measure_depth ${DOCU_PATH})))
    for (( i=rel_nesting_level; i>=0; i-- )); do
        printf "  " >> ${MAIN_TOUPDATE}
    done
    printf -- "- ${link_from}\n" >> ${MAIN_TOUPDATE}
    prev_file=${file}
done
# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu


for file in "${files_array[@]}"; do
    
    # creating link_to
    link_to=$(basename ${file})
    echo "# ${parentname} ${link_to} #" >> ${MAIN_TOUPDATE}  ## Actual link_to
    echo ${link_to} | figlet >> ${MAIN_TOUPDATE}
    cat ${file} >> ${MAIN_TOUPDATE}
done

# Deleting the modeline
sed -i '$ d' ${MAIN_TOUPDATE}


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
