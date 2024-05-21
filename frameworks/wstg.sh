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
https://owasp.org/www-project-web-security-testing-guide/stable/
)
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
    `## Directory Options` \
      --directory-prefix=${DOCU_PATH}/downloaded \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=4 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject '*.webp,*.mp4,*.ico,*.svg,*.js,*json,*.css,*.xml,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}
done 



##  Modifying documents
#  As later on the files are gonna be sorted alphabetically by path
#       and on the following path we have got
# "${DOCU_PATH}/downloaded/wireshark.org/docs/wsdg_html_chunked/"
#    we have got the following naming convention files that
#  ${DOCU_PATH}/downloaded/wireshark.org/docs/wsdg_html_chunked/ChTestRun.html
#      corresponding to 13.13._Listing And Running
#  ${DOCU_PATH}/downloaded/wireshark.org/docs/wsdg_html_chunked/ChToolsBash.html
#      coressponding to 4.8_bash
#   If sorted this way it will be parsed desorderly
#
#   Solution , modify filename

##mapfile -t files_array < <(find "${DOCU_PATH}/downloaded/wireshark.org/docs/wsdg_html_chunked/" -type f -name "*.html" )
##for file in "${files_array[@]}"; do
##    new_name=$(cat "$file" | pup 'div.navheader tbody tr:first-child' | pandoc -f html -t plain | sed 's/ /_/g; s/\./-/g; s/[^[:alnum:]_-]//g' )
##    dir_name=$(dirname "$file")
##    mv "$file" $dir_name/$new_name.html
##done
##
##mapfile -t files_array < <(find "${DOCU_PATH}/downloaded/wireshark.org/docs/wsug_html_chunked/" -type f -name "*.html" )
##for file in "${files_array[@]}"; do
##    new_name=$(cat "$file" | pup 'div.navheader tbody tr:first-child' | pandoc -f html -t plain | sed 's/ /_/g; s/\./-/g; s/[^[:alnum:]_-]//g' )
##    dir_name=$(dirname "$file")
##    mv "$file" $dir_name/$new_name.html
##done



## *jpg,*png,*gif
#      --wait-second=3 \
#      --waitretry=3 \
#      --random-wait \


##      -nH \

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
    f1() { pup -i 0 --pre 'section#div-main h1' | pandoc -f html -t plain;}
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
mapfile -t sorted_paths_array < <(printf "%s\n" "${!paths_linkto[@]}" | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')
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
    f1() { pup -i 0 --pre 'section#div-main' | pandoc -f html -t plain ; }
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

    ## Retrieving content of the files, removing Discussion lines
    cat "${content_dump}" >> ${MAIN_TOUPDATE}
    echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK

    rm "$content_dump"
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
