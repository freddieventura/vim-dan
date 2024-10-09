#!/bin/bash

# This is a ruleset for parsing .chm documents,
# Which is a Microsoft documentation format.
#   More info: https://en.wikipedia.org/wiki/Microsoft_Compiled_HTML_Help
# 
# They are used for documentation, manuals, ebooks. And it suits vim-dan capabilities
# Only the images will not be shown.
#
# The example below is a proof of concept on how to work with any
#   - Purhase a .chm and download its file

# DECLARING VARIABLES AND PROCESSING ARGS
# -------------------------------------
# (do not touch)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../scripts/helpers.sh"

DOCU_PATH="$1"
shift
#DOCU_NAME=$(basename ${0} '.sh')
DOCU_NAME='the-c-programming-language'
MAIN_TOUPDATE="${DOCU_PATH}/${DOCU_NAME}.chmdan"
DOWNLOAD_LINKS=(
https://en.wikipedia.org/wiki/The_C_Programming_Language
)
FILENAME="Brian W. Kernighan, Dennis M. Ritchie - The C programming language-Prentice Hall (1988).chm"
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS


indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

## THERE IS NO INDEXING PROCESS
## Download the resource as such I have 
## "John Shapley Gray - Interprocess Communication in Linux (2003, Prentice Hall) - libgen.li.chm"

}


arranging_rules() {

# rename all files withespaces to _  on filename
FILENAME=$(basename $(rename -v "s/ /_/g" "${DOCU_PATH}/downloaded/${FILENAME}" | sed -n 's/.*renamed as \(.*\)/\1/p'))

# Extract files
7z x ${DOCU_PATH}/downloaded/${FILENAME} -o${DOCU_PATH}/downloaded/
# Remove original file
rm ${DOCU_PATH}/downloaded/${FILENAME}


#
find ${DOCU_PATH}/downloaded/ -not -name "*.htm" -type f -delete
#


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

mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f \( -name "*.html" -or -name "*.htm" \) | sort -V )


## First create the title array
title_array=()
for file in "${files_array[@]}"; do

    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'h1' | pandoc -f html -t plain ; }  
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


# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}



## We need to order the documentation according to the linksFrom
## Ordering the keys in a new Array
mapfile -t sorted_paths_array < <(printf "%s\n" "${!paths_linkto[@]}" | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//' )
## Remember after this anytime we access the array
## We need to Iterate through each member of the array that correspond to the sorted keys
## When in need to retrieve the files , use the associative array

## JUST FOR DEBUGGING
##for file in "${sorted_paths_array[@]}"; do
##    echo ${file}
##done

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
    f1() { pup -i 0 --pre 'body' | pandoc -f html -t plain ;}

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
    sed -e '/^\s*\[\]$/d' \
        -e'/\[Previous Section\]/d' \
        -e'/\[Previous section\]/d' \
        -e '/\s*Top\s*$/d' \
        -e '/\s*-----*.*/d' \
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
