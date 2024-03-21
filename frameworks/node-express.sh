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
DOWNLOAD_LINK="https://expressjs.com/en/4x/api.html"
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS



indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

#--cut-dirs=4 
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
    `## Recursive Accept/Reject Options` \
      ${DOWNLOAD_LINK}
      
}

parsing_rules(){
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}

## MONO-FILE PARSING
## Only one file, parsing topics according to html structure of the document

mapfile -t topics_array < <(cat ${DOCU_PATH}/downloaded/api.html | pup -i 0 --pre '#api-doc h3' | pandoc -f html -t plain | sed '/^\s*$/d')


# Parsing our own index for docu
# -----------------------------------------------------------
# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}

for topic in "${topics_array[@]}"; do
    link_from="& ${topic} &"
    echo "- ${link_from}" >> ${MAIN_TOUPDATE}
done
# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu

echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK

# Parsing the whole document
# -----------------------------------------------------------
## Dump the documentation, with no nav, to a buffer file
cat ${DOCU_PATH}/downloaded/api.html | pup -i 0 --pre '#api-doc' | pandoc -f html -t plain > ${DOCU_PATH}/text-buffer.txt

## Mangle each topic line, to create linkTo
for topic in "${topics_array[@]}"; do
    perl -i -pe "s|^\Q${topic}\E$|# ${topic} #|g" ${DOCU_PATH}/text-buffer.txt
done

## Append text-buffer to MAIN_TOUPDATE , and delete text-buffer file
cat ${DOCU_PATH}/text-buffer.txt >> ${MAIN_TOUPDATE} 
rm ${DOCU_PATH}/text-buffer.txt 

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
