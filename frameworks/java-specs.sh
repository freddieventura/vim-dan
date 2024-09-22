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
DOWNLOAD_LINK="https://docs.oracle.com/javase/specs/jls/se21/html/index.html"
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
      -nH --cut-dirs=5 \
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
      --reject '*mp4,*.gif,*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}
}

parsing_rules(){

    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}

echo "Index" | figlet >> ${MAIN_TOUPDATE}
# Index has already been done by
# There we got all the links_From
# Correting two issues
#   - Empty lines
#   - Two contiguous whitespaces
#   - A whitespace before the Topic number
cat ${DOCU_PATH}/downloaded/index.html | pup -i 0 --pre 'div.toc' | pandoc -f html -t plain | sed '/^\s*$/d' | sed 's/[[:space:]][[:space:]]*/ /g' | sed -E 's/^[[:space:]]([0-9]+\.([0-9]+\.)*)/\1/' >> ${MAIN_TOUPDATE}

# Parsing all reference files into a single one
# linkTo are embedded on the files
# so
#    - First correcting whitespace issue on Index Bullet points
#     - Then Transforming their Index Bullet points into linkTo
mapfile -t files_array < <(find ${DOCU_PATH}/downloaded/ -name "*jls-*.html" | sort -V)

for file in "${files_array[@]}"; do
    cat ${file} | pup -i 0 --pre 'div.section' | pandoc -f html -t plain | sed -E 's/^[[:space:]]([0-9]+\.([0-9]+\.)*)/# \1/' | sed '/^\#[[:space:]]*[0-9]\+\.\([0-9]\+\.\)*/ s/$/ #/' >> ${MAIN_TOUPDATE}
done

}


## PARSING ARGUMENTS
## ------------------------------------
# (do not touch)
while getopts ":ipa" opt; do
    case ${opt} in
        i)
            indexing_rules
            ;;
        p)
            parsing_rules
            ;;
        a)
            arranging_rules
            ;;
        h | *)
            echo "Usage: $0 [-i] [-p] [-a] [-h] "
            echo "Options:"
            echo "  -i  Indexing"
            echo "  -p  Parsing"
            echo "  -a  Arranging"
            echo "  -h  Help"
            exit 0
            ;;
    esac
done
## EOF EOF EOF PARSING ARGUMENTS
## ------------------------------------
