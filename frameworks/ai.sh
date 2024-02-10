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
DOWNLOAD_LINK="https://ai-scripting.docsforadobe.dev/"
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS


indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

    wget \
    `## Basic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
    `## Download Options` \
      --timestamping \
    `## Directory Options` \
      --directory-prefix=${DOCU_PATH}/downloaded \
      -nH \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=4 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject '*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}
}

parsing_rules(){
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}



    cat ${DOCU_PATH}/downloaded/index.html | pup -i 0 --pre '.rst-content' | pandoc -f html -t plain >> ${MAIN_TOUPDATE}

    # Parsing topics (sorting by path, then alphabetically)
    mapfile -t dirs_array < <(find ${DOCU_PATH}/downloaded/ -type d -name "*" | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')
     
    for file in "${dirs_array[@]}"; do
        mapfile -t files_array < <(find ${dirs_array} -type f -name "*" | sort )

        for file in "${files_array[@]}"; do

            cat ${file} | pup 'section h1' | pandoc -f html -t plain | sed 's/¶//g' > ${DOCU_PATH}/topic-header-toupdate.txt
            cat ${file} | pup 'section h1' | pandoc -f html -t plain | sed 's/¶//g' | figlet >> ${DOCU_PATH}/topic-header-toupdate.txt
            cat ${file} | pup -i 0 --pre 'li.current' | pandoc -f html -t plain >> ${DOCU_PATH}/topic-header-toupdate.txt

            sed -i '1s/^/# /; 1s/$/ #/' ${DOCU_PATH}/topic-header-toupdate.txt
            cat ${file} | pup -i 0 --pre '.rst-content' | pandoc -f html -t plain > ${DOCU_PATH}/topic-body-toupdate.txt
            sed -i 's/¶/#/g' ${DOCU_PATH}/topic-body-toupdate.txt
            cat ${DOCU_PATH}/topic-header-toupdate.txt >> ${MAIN_TOUPDATE}
            cat ${DOCU_PATH}/topic-body-toupdate.txt >> ${MAIN_TOUPDATE}
        done
    done

    # Deleting buffer files
    rm ${DOCU_PATH}/topic-header-toupdate.txt
    rm ${DOCU_PATH}/topic-body-toupdate.txt
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
