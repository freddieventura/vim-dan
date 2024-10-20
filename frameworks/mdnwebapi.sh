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
DOWNLOAD_LINK="https://developer.mozilla.org/en-US/docs/Web/API"
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
      -nH --cut-dirs=3 \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=4 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject '*.gif,*jpg,*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      --exclude-directories=en-US/docs/Web/Accessibility,en-US/docs/Web/Accessibility/*,en-US/docs/Web/CSS,en-US/docs/Web/CSS/*,en-US/docs/Web/HTML,en-US/docs/Web/HTML/*,en-US/docs/Web/Media,en-US/docs/Web/Media/*,en-US/docs/Web/XML,en-US/docs/Web/XML/*,/en-US/docs/Web/Manifest,/en-US/docs/Web/Manifest/*,/en-US/docs/Web/MathML,/en-US/docs/Web/MathML/*,/en-US/docs/Web/EXSLT,/en-US/docs/Web/EXSLT/*,/en-US/docs/Web/SVG,/en-US/docs/Web/SVG/*,/en-US/docs/Web/XSLT,/en-US/docs/Web/XSLT/*,/en-US/docs/Web/Events,/en-US/docs/Web/Events/*,/en-US/docs/Web/Guide,/en-US/docs/Web/Guide/*,/en-US/docs/Web/Progressive_web_apps,/en-US/docs/Web/Progressive_web_apps/*,/en-US/docs/Web/Performance,/en-US/docs/Web/Performance/*,/en-US/docs/Web/XPath,/en-US/docs/Web/XPath/*,/en-US/docs/Web/Security,/en-US/docs/Web/Security/*,/en-US/docs/Web/JavaScript,/en-US/docs/Web/JavaScript/*,/en-US/docs/Web/HTTP,/en-US/docs/Web/HTTP/* \
      --reject-regex '\\\"' \
      --page-requisites \
      ${DOWNLOAD_LINK}

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
measure_depth() { echo "${*#/}" | awk -F/ '{print NF}'; }
echo "index" | figlet >> ${MAIN_TOUPDATE}


mapfile -t files_array < <(find ${DOCU_PATH}/downloaded/ -type f -name "*" | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')

for file in "${files_array[@]}"; do

    # If in need to calculate parent directory for hierarchy
    parentname="$(basename "$(dirname "$file")")"
    parentname_prev="$(basename "$(dirname "$prev_file")")"
    if [[ ${parentname} != ${parentname_prev} ]]; then
        echo "- ${parentname}" >> ${MAIN_TOUPDATE}
    fi

    link_from="& @${parentname}@ $(cat ${file} | pup 'article h1' | pandoc -f html -t plain)&"
    rel_nesting_level=$(($(measure_depth ${file})-$(measure_depth ${DOCU_PATH})))
    for (( i=rel_nesting_level; i>=0; i-- )); do
        printf "  " >> ${MAIN_TOUPDATE}
    done
    echo "- ${link_from}" >> ${MAIN_TOUPDATE}
    prev_file=${file}
done
# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu




    # Parsing topics (sorting by path, then alphabetically)
    mapfile -t files_array < <(find ${DOCU_PATH}/downloaded/API -type f -name "*" | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')

    for file in "${files_array[@]}"; do

        # creating link_to
        parentname="$(basename "$(dirname "$file")")"
        link_to=$(cat ${file} | pup -i 0 --pre 'header h1' | pandoc -f html -t plain )
        echo "# ${parentname} ${link_to} #" >> ${MAIN_TOUPDATE}  ## Actual link_to
        echo ${link_to} | figlet >> ${MAIN_TOUPDATE}
 

        #Parsing content
        cat ${file} | pup -i 0 --pre '#content' | pandoc -f html -t plain >> ${MAIN_TOUPDATE}
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
