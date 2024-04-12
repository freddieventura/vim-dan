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
DOWNLOAD_LINK=""
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS



indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

url_array=(
https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes--0-499-
https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands
)

for url in "${url_array[@]}"; do
    wget \
    `## Basic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
      -o ${DOCU_PATH}/wget.log \
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
      ${url}
done 

mv ${DOCU_PATH}/downloaded/en-us/windows/win32/debug ${DOCU_PATH}/downloaded/
mv ${DOCU_PATH}/downloaded/en-us/windows-server/administration/windows-commands ${DOCU_PATH}/downloaded/

wget https://www.groovypost.com/howto/windows-10-keyboard-shortcuts/ -O ${DOCU_PATH}/downloaded/windows10-keyboard-shortcuts.html

git clone https://github.com/MicrosoftDocs/PowerShell-Docs ${DOCU_PATH}/downloaded


## Preparing files for processing
## -----------------------------
echo "Preparing the files for processing ..."

set -x
# Removing every directory that is not ./reference "debug" 
find ${DOCU_PATH}/downloaded/ -mindepth 1 -maxdepth 1 ! \( -name "reference" -o -name "debug" -o -name "windows-commands" -o -name "windows10-keyboard-shortcuts.html" \) -exec rm -rf {} \;
# Removing every file in reference that is not .md
find ${DOCU_PATH}/downloaded/reference -type f -not -name "*.md" -exec rm {} \;
# Moving Reference one level down
mv ${DOCU_PATH}/downloaded/reference/* ${DOCU_PATH}/downloaded/


# Removing every directory that is not 7.5 , docs-conceptual , debug, administration
find ${DOCU_PATH}/downloaded/ -mindepth 1 -maxdepth 1 ! \( -name "7.5" -o -name "docs-conceptual" -o -name "debug" -o -name "windows-commands" -o -name "windows10-keyboard-shortcuts.html" \) -exec rm -rf {} \;
## eof eof eof Preparing files for processing
## -----------------------------

}

parsing_rules(){
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : " >> ${MAIN_TOUPDATE}
    echo " - https://github.com/MicrosoftDocs/PowerShell-Docs" >> ${MAIN_TOUPDATE}
    echo " - https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes--0-499-" >> ${MAIN_TOUPDATE}
    echo " - https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands" >> ${MAIN_TOUPDATE}
    echo " - https://www.groovypost.com/howto/windows-10-keyboard-shortcuts/" >> ${MAIN_TOUPDATE}
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

mapfile -t files_array < <(find ${DOCU_PATH}/downloaded -type f )


## First create the title array
title_array=()
for file in "${files_array[@]}"; do

    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'div .content h1' | pandoc -f html -t plain; }
    f2() { pup -i 0 --pre 'header h1' | pandoc -f html -t plain; }
    title_parsing_array=(f1 f2)

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

set -x
# Parsing and appending content , using Multi-rule
# -----------------------------------------------------------
## We need to Iterate through each member of the array that correspond to the sorted keys
for path in "${sorted_paths_array[@]}"; do
    ## Creating Link_to
    parentname="$(basename "$(dirname ${path})")"
    echo "# ${parentname} ${paths_linkto[${path}]} #" >> ${MAIN_TOUPDATE}
    echo ${paths_linkto[${path}]} | figlet  >> ${MAIN_TOUPDATE}

    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'div .content' | pandoc -f html -t plain; }
    f2() { pup -i 0 --pre 'div.post-cont-out' | pandoc -f html -t plain; }
    content_parsing_array=(f1 f2)

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
       cat ${path} | pandoc -f markdown -t plain > "$content_dump"
    fi

    ## Retrieving content of the files, removing the yaml
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
