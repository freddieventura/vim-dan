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
DOWNLOAD_LINK="https://reactnative.dev/"
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS


indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

    wget \
    `##tBasic Startup Options` \
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
      --reject '*.webp,*.mp4,*.ico,*.gif,*.jpg,*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}

}

arranging_rules() {

## Preparing documents
find ${DOCU_PATH}/downloaded/ -mindepth 1 -maxdepth 1 ! -name "docs" -exec rm -rf {} \;
find ${DOCU_PATH}/downloaded/docs -type d -mindepth 1 -maxdepth 1 ! -name "the-new-architecture" -exec rm -rf {} \;
mv ${DOCU_PATH}/downloaded/docs/* ${DOCU_PATH}/downloaded/
rmdir ${DOCU_PATH}/downloaded/docs

}


parsing_rules(){
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}


mapfile -t files_array < <(find ${DOCU_PATH}/downloaded -name *.html | sort )
for file in "${files_array[@]}"; do
    ## Creating an associative array with the links_from (links_to) and their filename
    # Declare an associative array
    declare -A links_to_paths

    # Use process substitution to run both find commands simultaneously
    while IFS= read -r key && IFS= read -r value <&3; do
    # Assign the key-value pair to the associative array
    links_to_paths["$key"]="$value"
    done < <(cat ${file} |pup -i 0 --pre 'header' | pandoc -f html -t plain ) \
       3< <(echo ${file})
    
done

## We need to order the documentation according to the linksFrom
## Ordering the keys in a new Array
mapfile -t sorted_links_to_paths < <(printf "%s\n" "${!links_to_paths[@]}" | sort -t = -k 1)
## Remember after this anytime we access the array
## We need to Iterate through each member of the array that correspond to the sorted keys
## When in need to retrieve the files , use the associative array

# Parsing our own index for docu
# -----------------------------------------------------------
# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}


## We need to Iterate through each member of the array that correspond to the sorted keys
for key in "${sorted_links_to_paths[@]}"; do
    link_from="& ${key} &"
    echo "- ${link_from}" >> ${MAIN_TOUPDATE}
done

# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu

echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK

# Parsing each manpage
# -----------------------------------------------------------
## We need to Iterate through each member of the array that correspond to the sorted keys
for key in "${sorted_links_to_paths[@]}"; do
    ## Creating Link_to
    echo "# ${key} #" >> ${MAIN_TOUPDATE} 
    echo ${key} | figlet  >> ${MAIN_TOUPDATE} 

    ## When in need to retrieve the files , use the associative array
    ## getting the nav
    cat ${links_to_paths[${key}]} | pup -i 0 --pre 'ul.table-of-contents'| pandoc -f html -t plain  >> ${MAIN_TOUPDATE} 
    ## getting the article
    cat ${links_to_paths[${key}]} | pup -i 0 --pre 'div.theme-doc-markdown'| pandoc -f html -t plain  >> ${MAIN_TOUPDATE} 
    echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK
done

## Final Corrections
sed -i "s/$(echo -ne '\u200b')//g" ${MAIN_TOUPDATE}
sed -i 's/\[\]//g' ${MAIN_TOUPDATE}

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
