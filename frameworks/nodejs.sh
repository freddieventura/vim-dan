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
DOWNLOAD_LINK="https://nodejs.org/dist/latest-v16.x/docs/api/index.html"
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
      -nH --cut-dirs=4 \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=2 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject '*jpg,*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      ${DOWNLOAD_LINK}
      
    ## PREPARING THE FILES FOR PROCESSING
    echo "Preparing the files for processing ..."

    rm ${DOCU_PATH}/downloaded/all.html
    rm ${DOCU_PATH}/downloaded/index.html
}

parsing_rules(){
    # Header of docu    
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
    done < <(cat ${file} | pup -i 0 --pre '#apicontent h2' | pandoc -f html -t plain |sed -e 's/[ \t]*#[ \t]*$//') \
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
    parentname="$(basename "$(dirname ${links_to_paths[${key}]})")"
    link_from="& @${parentname}@ ${key} &"
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
    parentname="$(basename "$(dirname ${links_to_paths[${key}]})")"
    echo "# ${parentname} ${key} #" >> ${MAIN_TOUPDATE}
    echo ${key} | figlet  >> ${MAIN_TOUPDATE}

    ## When in need to retrieve the files , use the associative array
    cat ${links_to_paths[${key}]} | pup -i 0 --pre 'details' | pandoc -f html -t plain | sed -e 's/[ \t]*#[ \t]*$//' >> ${MAIN_TOUPDATE}
    cat ${links_to_paths[${key}]} | pup -i 0 --pre '#apicontent' | pandoc -f html -t plain | sed -e 's/[ \t]*#[ \t]*$/#/' >> ${MAIN_TOUPDATE}
    echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK
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
