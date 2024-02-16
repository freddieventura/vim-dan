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
DOWNLOAD_LINK="https://docs.oracle.com/javase/tutorial/"
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
      -nH --cut-dirs=2 \
      --directory-prefix=${DOCU_PATH}/downloaded \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=4 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject '*.java,*.sql,*.jar,*.jpg,*.zip,*.GIF,*mp4,*.gif,*.svg,*.js,*json,*.css,*.PNG,*.png,*.xml,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}
}

parsing_rules(){

    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}

# Index has already been done by
# There we got all the links_From
cat ${DOCU_PATH}/downloaded/reallybigindex.html | pup 'body' | pandoc -f html -t plain | head -n -7 | tail -n +10 | sed '/^\s*$/d' |sed 's/^/\& /' | sed 's/$/ \&/' | sed 's/^/- /' >> ${MAIN_TOUPDATE}

## TODO
## Problem on order of topics
## It will go by subdirs , then next subdirs , so its not specifically in the right order
mapfile -t files_array < <(find ${DOCU_PATH}/downloaded/ -type f -name "*" | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')
#mapfile -t files_array < <(find ${DOCU_PATH}/downloaded/ -type f -name "*" | sort )
    for file in "${files_array[@]}"; do
        # creating link_to
        link_to=$(cat ${file} | pup -i 0 --pre 'div#PageTitle' | pandoc -f html -t plain )
        echo "# ${link_to} #" >> ${MAIN_TOUPDATE}  ## Actual link_to
        cat ${file} | pup -i 0 --pre 'div#PageContent' | pandoc -f html -t plain >> ${MAIN_TOUPDATE}
    done
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
