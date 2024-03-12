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
DOWNLOAD_LINK="https://manpag.es/debian-bookworm/"
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS


indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

##      --accept-regex 'https://manpag.es/debian-bookworm/\n+\.*' \
##      --accept '*.html,*.txt' \
##      ${DOWNLOAD_LINK}
##    --input-file=$CURRENT_DIR/links.txt \
##      --accept '*.html,*.txt' \
    wget \
    `## Basic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
    -o ./wget.log \
    `## Download Options` \
      --timestamping \
    `## Directory Options` \
      -nH \
      --directory-prefix=${DOCU_PATH}/downloaded \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
      --content-disposition \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=2 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject '?pdf,*.png*,*jpg,*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      --exclude-directories="debian-bookworm/de,debian-bookworm/de/*,debian-bookworm/ja,debian-bookworm/ja/*,debian-bookworm/pt,debian-bookworm/pt/*,debian-bookworm/tr,debian-bookworm/tr/*,static,static/*" \
      --page-requisites \
      https://manpag.es/debian-bookworm/1+ \
      https://manpag.es/debian-bookworm/2+ \
      https://manpag.es/debian-bookworm/3+ \
      https://manpag.es/debian-bookworm/4+ \
      https://manpag.es/debian-bookworm/5+ \
      https://manpag.es/debian-bookworm/6+ \
      https://manpag.es/debian-bookworm/7+ \
      https://manpag.es/debian-bookworm/8+ \
      https://manpag.es/debian-bookworm/9+ 

DOCU_PATH='.'
## PREPARING THE FILES FOR PROCESSING
echo "Preparing the files for processing ..."

rm -r ${DOCU_PATH}/downloaded/static/
rm -r ${DOCU_PATH}/downloaded/debian-bookworm/de
rm -r ${DOCU_PATH}/downloaded/debian-bookworm/ja
rm -r ${DOCU_PATH}/downloaded/debian-bookworm/pt
rm -r ${DOCU_PATH}/downloaded/debian-bookworm/tr
find ${DOCU_PATH}/downloaded -type f -name *?pdf -exec rm {} \;
mv ${DOCU_PATH}/downloaded/debian-bookworm/* ${DOCU_PATH}/downloaded/
rm -r ${DOCU_PATH}/downloaded/debian-bookworm


## Renaming files with whitespaces to _
rename "s/ /_/g" ${DOCU_PATH}/downloaded/*

## FILTERING FILES
# there are some files that link to other files but they 
# are not documentation itself
# this can be seen by the non match of 'pdf 'string

# We are deleting these straightaway

DOCU_PATH='.'
mapfile -t files_array < <(find ${DOCU_PATH}/downloaded -name *.html )

for file in "${files_array[@]}"; do
    # If file doesnt have such an occurence delete
    if ! grep -q ">pdf" ${file} ; then
        rm "${file}"
    fi
done

}

parsing_rules(){
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}


set -x
mapfile -t files_array < <(find ${DOCU_PATH}/downloaded -name *.html | sort )
for file in "${files_array[@]}"; do
    ## Creating an associative array with the links_from (links_to) and their filename
    # Declare an associative array
    declare -A links_to_paths

    # Use process substitution to run both find commands simultaneously
    while IFS= read -r key && IFS= read -r value <&3; do
    # Assign the key-value pair to the associative array
    links_to_paths["$key"]="$value"
    done < <(cat ${file} | pandoc -f html -t plain | grep -A2 'pdf' | head -n 3 | tail -n 1) \
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
    cat ${links_to_paths[${key}]} | pup -i 0 --pre 'div#manpage' | pandoc -f html -t plain  >> ${MAIN_TOUPDATE} 
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
