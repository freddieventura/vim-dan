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
DOWNLOAD_LINKS=(
https://docs.llamaindex.ai/
)
#DOWNLOAD_LINK=""
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS



indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
    wget \
    `##tBasic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
      -o ./wget.log \
    `## Download Options` \
      --timestamping \
      --restrict-file-names=windows \
    `## Directory Options` \
      --directory-prefix=${DOCU_PATH}/downloaded \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=inf \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject-regex '.*?hel=.*|.*?hl=.*' \
      --reject '*.pdf,*.woff,*.woff2,*.ttf,*.png,*.webp,*.mp4,*.ico,*.svg,*.js,*json,*.css,*.xml,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}
done 

}

arranging_rules(){

## Making a backup
cp -r "${DOCU_PATH}/downloaded" "${DOCU_PATH}/downloaded-bk"

## Cleaning up documents

## Removing useless documents
rm -r ${DOCU_PATH}/downloaded/docs.llamaindex.ai/cdn-cgi
rm ${DOCU_PATH}/downloaded/docs.llamaindex.ai/index.html
rm -r ${DOCU_PATH}/downloaded/docs.llamaindex.ai/en/latest

rm -r ${DOCU_PATH}/downloaded/docs.llamaindex.ai/en/stable/_static
rm -r ${DOCU_PATH}/downloaded/docs.llamaindex.ai/en/stable/presentations


## Bring it all down one subdir from host directory
mv ${DOCU_PATH}/downloaded/docs.llamaindex.ai/en/stable/* ${DOCU_PATH}/downloaded/
rm -r ${DOCU_PATH}/downloaded/docs.llamaindex.ai

## Modifying documents

## Rename lone index.html to subdir folder and place this file a level down
## For instance
## www.zaproxy.org/docs/alerts/
## www.zaproxy.org/docs/alerts/0/index.html
## should become
## www.zaproxy.org/docs/alerts/0.html


mapfile -t files_array < <(find "${DOCU_PATH}/downloaded/" -type f -name "index.html")
for file in "${files_array[@]}"; do
    parent="$(basename "$(dirname ${file})")"
    dirname=$(dirname ${file})
    ext=${file##*.}
    mv ${file} "$dirname/../$parent.$ext";
done

## Removing empty dirs

find "${DOCU_PATH}/downloaded/" -type d -empty -delete

}

parsing_rules(){
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from :" >> ${MAIN_TOUPDATE}
    for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
        echo " - ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    done 
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}


## MULTI-FILE PARSING WITH MULTI-RULE
## Parsing into an associative array each title and path
## With this we can :
##      - Create an ordered automated index linkFrom
##      - Append each topic content with a linkTo and a figlet header
##
## Also there are different parsing rules (multi-rule)
##      - Meaning they will be applied to each file sequencially
##      - Upon one parsing rule returning non-zero, that parsed title will be added 

#mapfile -t files_array < <(find ${DOCU_PATH}/downloaded -type f )

mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" )


## First create the title array
title_array=()
for file in "${files_array[@]}"; do

    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'article h1' | pandoc -f html -t plain | sed 's/ #//' ;}
    title_parsing_array=(f1)

    found_selector=""
    for title_parsing in "${title_parsing_array[@]}"; do
        title=$("$title_parsing" < "$file")
        if [ -n "$title" ]; then
            found_selector=true
            break
        fi
    done

    # Default case for parsing , if none of the rules return a non-zero string
    if [ -z "$found_selector" ]; then
       title=$(basename "$file" | cut -f 1 -d '.')
    fi

    # Append the value of title to the title_array
    title_array+=("$title")
done


## Creating an associative array to map titles to file paths


declare -A paths_linkto

# Iterate through the indices of 'files_array'
for index in "${!files_array[@]}"; do
    file="${files_array[$index]}"
    title="${title_array[$index]}"

    # Assign the key-value pair to the associative array 'paths_linkto'
    paths_linkto["$file"]="$title"
done



## We need to order the documentation according to the linksFrom
## Ordering the keys in a new Array
mapfile -t sorted_paths_array < <(printf "%s\n" "${!paths_linkto[@]}" | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//' )
## Remember after this anytime we access the array
## We need to Iterate through each member of the array that correspond to the sorted keys
## When in need to retrieve the files , use the associative array

## JUST FOR DEBUGGING
for file in "${sorted_paths_array[@]}"; do
    echo ${file}
done

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

# Parsing and appending content , using Multi-rule
# -----------------------------------------------------------
## We need to Iterate through each member of the array that correspond to the sorted keys
for path in "${sorted_paths_array[@]}"; do
    ## Creating Link_to
    parentname="$(basename "$(dirname ${path})")"
    echo "# ${parentname} ${paths_linkto[${path}]} #" >> ${MAIN_TOUPDATE}
    echo ${paths_linkto[${path}]} | figlet  >> ${MAIN_TOUPDATE}

    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'article' | pandoc -f html -t plain ;}

    content_parsing_array=(f1)

    found_selector=""
    content_dump=$(mktemp)
    for content_parsing in "${content_parsing_array[@]}"; do
        "$content_parsing" < "$path" > "$content_dump"
        if [ 1 -lt $(stat -c %s "${content_dump}") ];then
            found_selector=true
            break
        fi
    done

    # Default case for parsing , if none of the rules return a non-zero string
    if [ -z "$found_selector" ]; then
       cat ${path} | pandoc -f html -t plain > "$content_dump"
    fi

    ## Retrieving content of the files and cleaning it
    sed -e 's/ #$//g' \
        "${content_dump}" >> "${MAIN_TOUPDATE}"    
    echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK

    rm "$content_dump"
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
