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
https://sourceware.org/glibc/manual/latest/html_node/libc-html_node.tar.gz
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
    `## Directory Options` \
      --directory-prefix=${DOCU_PATH}/downloaded \
      ${DOWNLOAD_LINK}
done 
}

arranging_rules(){

## Cleaning up documents

mv ${DOCU_PATH}/downloaded/libc/* ${DOCU_PATH}/downloaded/
rmdir ${DOCU_PATH}/downloaded/libc 

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
    f1() { pup -i 0 --pre '.appendixsec' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f2() { pup -i 0 --pre '.appendix' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f3() { pup -i 0 --pre '.subsubsection' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f4() { pup -i 0 --pre '.subsection' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f5() { pup -i 0 --pre '.section' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f6() { pup -i 0 --pre '.chapter' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f7() { pup -i 0 --pre '.appendixsec-level-extent' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f8() { pup -i 0 --pre '.subsubsection-level-extent' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f9() { pup -i 0 --pre '.subsection-level-extent' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f10() { pup -i 0 --pre '.section-level-extent' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    f11() { pup -i 0 --pre '.chapter-level-extent' | pandoc -f html -t plain | head -n 1 | sed 's/¶//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' ;}
    title_parsing_array=(f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11)

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

 
for TITLE in "${title_array[@]}"; do
    echo "TITLE : ${TITLE}" >&2 ## DEBUGGING
done

 
for FILE in "${files_array[@]}"; do
    echo "FILE : ${FILE}" >&2 ## DEBUGGING
done



## Creating an associative array to map titles to file paths


declare -A title_to_path

# Iterate through the indices of 'files_array'
for index in "${!files_array[@]}"; do
    file="${files_array[$index]}"
    title="${title_array[$index]}"

    # Assign the key-value pair to the associative array 'paths_linkto'
    title_to_path["$title"]="$file"
done



## We need to order the documentation according to the linksFrom
## Ordering the keys in a new Array
mapfile -t sorted_titles_array < <(printf "%s\n" "${!title_to_path[@]}" | sort -n )
## Remember after this anytime we access the array29.2 Controlling Terminal of a Process:
## We need to Iterate through each member of the array that correspond to the sorted keys
## When in need to retrieve the files , use the associative array


# Iterating through the associative array
for key in "${!sorted_titles_array[@]}"; do
    echo "Key: $key, Value: ${sorted_titles_array[$key]}" >&2
done



# This will be the linkFrom items
############echo "index" | figlet >> ${MAIN_TOUPDATE}


## We need to Iterate through each member of the array that correspond to the sorted keys
for title in "${sorted_titles_array[@]}"; do
    parentname="$(basename "$(dirname  "${title_to_path[$title]}")")"
    parentname_prev="$(basename "$(dirname "$prev_file")")"

    if [[ ${parentname} != ${parentname_prev} ]]; then
        echo "- ${parentname}" >> ${MAIN_TOUPDATE}
    fi

    link_from="& @${parentname}@ "${title}" &"
    echo "    - ${link_from}" >> ${MAIN_TOUPDATE}
    prev_file="${title_to_path[$title]}"
done

# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu

echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK

# Parsing and appending content , using Multi-rule
# -----------------------------------------------------------
## We need to Iterate through each member of the array that correspond to the sorted keys
for title in "${sorted_titles_array[@]}"; do
    ## Creating Link_to
    parentname="$(basename "$(dirname "${title_to_path[$title]}")")"
    echo "# ${parentname} ${title} #" >> ${MAIN_TOUPDATE}
    echo ${title} | sed 's/^[0-9]\+\(\.[0-9]\+\)* //' | figlet  >> ${MAIN_TOUPDATE}

    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'body' | pandoc -f html -t plain | sed 's/¶//g' ;}

    content_parsing_array=(f1)

    found_selector=""
    content_dump=$(mktemp)
    for content_parsing in "${content_parsing_array[@]}"; do
        "$content_parsing" < "${title_to_path[$title]}" | tail -n +5 | head -n -4 > "$content_dump"
        if [ 1 -lt $(stat -c %s "${content_dump}") ];then
            found_selector=true
            break
        fi
    done

    # Default case for parsing , if none of the rules return a non-zero string
    if [ -z "$found_selector" ]; then
       cat "${title_to_path[$title]}" | pandoc -f html -t plain > "$content_dump"
    fi

    ## Retrieving content of the files and cleaning it
    sed -e '/^\[\]$/d' \
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
