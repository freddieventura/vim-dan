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
DOWNLOAD_LINK="https://react.dev/"
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
     ## -o ${DOCU_PATH}/wget.log \
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
      --recursive --level=2 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --exclude-directories="next,next/*,category,category/*" \
      --reject '*.webp,*.woff2,image?*,*.ico,*.jpg,*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      ${DOWNLOAD_LINK}
}

arranging_rules() {

## Making a backup
cp -r "${DOCU_PATH}/downloaded" "${DOCU_PATH}/downloaded-bk"
 

# Removing every directory that is not learn and reference , and leaving all .html on the main dir
find ${DOCU_PATH}/downloaded/ -mindepth 1 -maxdepth 1 ! \( -name "*.html" -o -name "learn" -o -name "reference" \) -exec rm -rf {} \;

}

     

parsing_rules(){
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}


## MULTI-FILE PARSING
## Parsing into an associative array, each topic link and its path
## With this we can :
##      - Create an ordered automated index linkFrom
##      - Append each topic content with a linkTo and a figlet header

mapfile -t files_array < <(find ${DOCU_PATH}/downloaded -name *.html )
for file in "${files_array[@]}"; do
    ## Creating an associative array with the links_from (links_to) and their filename
    # Declare an associative array
    declare -A paths_linkto

    # Use process substitution to run both find commands simultaneously
    while IFS= read -r key && IFS= read -r value <&3; do
    # Assign the key-value pair to the associative array
    paths_linkto["$key"]="$value"
done < <(echo ${file} )\
       3< <(cat ${file} | pup -i 0 --pre "main article h1" | pandoc -f html -t plain | sed 's/\[\]//g')
    
done

## We need to order the documentation according to the linksFrom
## Ordering the keys in a new Array
mapfile -t sorted_paths_array < <(printf "%s\n" "${!paths_linkto[@]}" | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')
## Remember after this anytime we access the array
## We need to Iterate through each member of the array that correspond to the sorted keys
## When in need to retrieve the files , use the associative array


# Parsing our own index for docu
# -----------------------------------------------------------
# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}


## We need to Iterate through each member of the array that correspond to the sorted keys
for path in "${sorted_paths_array[@]}"; do

    parentname="$(basename "$(dirname ${path})")"
    parentname_prev="$(basename "$(dirname "$prev_file")")"

    if [[ ${parentname} != ${parentname_prev} ]]; then
        echo "- ${parentname}" >> ${MAIN_TOUPDATE}
    fi

    link_from="& @${parentname}@ ${paths_linkto[${path}]} &"
    echo "    - ${link_from}" >> ${MAIN_TOUPDATE}
    prev_file=${path}
done

# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu

echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK

# Parsing each manpage
# -----------------------------------------------------------
## We need to Iterate through each member of the array that correspond to the sorted keys
for path in "${sorted_paths_array[@]}"; do
    ## Creating Link_to
    parentname="$(basename "$(dirname ${path})")"
    echo "# ${parentname} ${paths_linkto[${path}]} #" >> ${MAIN_TOUPDATE}
    echo ${paths_linkto[${path}]} | figlet  >> ${MAIN_TOUPDATE}

    ## When in need to retrieve the files , use the associative array
    cat ${path} | pup -i 0 --pre 'main article' | pandoc -f html -t plain >> ${MAIN_TOUPDATE}
    echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK
done

    ## Cleaning out some residual lines
#    sed -i '/^$/{:a;N;s/\n$//;ta}' ${MAIN_TOUPDATE}
    sed -i 's/\[\]//g' ${MAIN_TOUPDATE}
#    sed -i '/^\[\] \[\]$/d' ${MAIN_TOUPDATE}
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
