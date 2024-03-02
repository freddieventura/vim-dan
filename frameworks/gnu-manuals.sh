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
DOWNLOAD_LINK="https://www.gnu.org/manual/manual.html"
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
      --output-file=./wget.log \
    `## Download Options` \
      --timestamping \
    `## Directory Options` \
      -nH \
      --directory-prefix=./downloaded \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safar      i/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=3 \
    `## Recursive Accept/Reject Options` \
      --accept '*.html,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}

    ## PENDING TO DELETE ALL THE NON-USED FILES

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


mapfile -t files_array < <(find ${DOCU_PATH}/downloaded/software/*/manual -type f -name *.txt)

for file in "${files_array[@]}"; do
    link_from="& $(basename ${file} .txt) &"
    echo "- ${link_from}" >> ${MAIN_TOUPDATE}
done
# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu



for file in "${files_array[@]}"; do

    # link_to
    link_to=$(basename ${file} .txt)
    echo "# ${link_to} #" >> ${MAIN_TOUPDATE}  ## Actual link_to

    # getting the filename as title
    basename ${file} .txt | figlet >> ${MAIN_TOUPDATE}

    # Creating an automatic navigation section
    # ----------------------------------------
    # Parsing headers
    mapfile -t headers_l1_array < <(sed -n -E '/^\**\*$/{x;p;d;}; x' ${file})
    mapfile -t headers_l2_array < <(sed -n -E '/^=*=$/{x;p;d;}; x' ${file})
    mapfile -t headers_l3_array < <(sed -n -E '/^-*-$/{x;p;d;}; x' ${file})

    headers_array=("${headers_l1_array[@]}" "${headers_l2_array[@]}" "${headers_l3_array[@]}")
    IFS=$'\n' headers_array=($(sort -n <<<"${headers_array[*]}"))
    unset IFS

    # Creating headers_link_from
    for header in "${headers_array[@]}"; do
        link_from="& @$(basename ${file} .txt)@ ${header} &"
        echo "- ${link_from}" >> ${MAIN_TOUPDATE}
    done
    # ----------------------------------------
    # EOF EOF EOF Creating an automatic navigation section


    # Dumping document Creating headers_link_to
    awk -v myFile=$(basename ${file} .txt) '/(^=+$|^\**\*$|^-*-$)/{prev = "# @"myFile"@ " prev " #"; next} NR > 1 {print prev} {prev = $0} END {print prev}' ${file} >> ${MAIN_TOUPDATE}
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
