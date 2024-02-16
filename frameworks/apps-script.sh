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
DOWNLOAD_LINK="https://developers.google.com/apps-script/"
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
      -nH --cut-dirs=1 \
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
      --include="apps-script,apps-script/*" \
      --reject '*mp4,*.gif,*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      --reject-regex '.*?hel=.*|.*?hl=.*' \
      --page-requisites \
      ${DOWNLOAD_LINK}
      
}

parsing_rules(){

    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}


## PRECALCULATING ARRAYS
# -----------------------------------------------------------

## We will be creating some arrays ourselves sequencially 
## So we achieve a logical order on documentation parsing

## The following will be the topics to be appended
## Will be the product of our sequencial find commands
declare -a files_array

## Level one files, they are the Index of the different API's
## (called services in Google , i.e: Spreadsheet Service)
mapfile -t level_one_files_array < <(find "${DOCU_PATH}/downloaded/reference" -maxdepth 1 -type f | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')

## EOF EOF EOF PRECALCULATING ARRAYS
# -----------------------------------------------------------


# Creating a manual index of the documentation
# -----------------------------------------------------------
# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}

for level_one_file in "${level_one_files_array[@]}"; do
    # Always adding each member to files_array
    files_array+=("${level_one_file}")


    # Parsing level_one list Item
    link_from=$(cat ${level_one_file} | pup -i 0 --pre 'h1.devsite-page-title' | pandoc -f html -t plain)
    echo "- &${link_from}&" >> ${MAIN_TOUPDATE}

    directory="${level_one_file%.html}/"

    # Iterate through children of the level_one to get level_two members
    mapfile -t level_two_files_array < <(find ${directory} -maxdepth 1 -type f  | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')

    for level_two_file in "${level_two_files_array[@]}"; do
        # Always adding each member to files_array
        files_array+=("${level_two_file}")

        # Parsing level_two list item
        link_from=$(cat ${level_two_file} | pup -i 0 --pre 'h1.devsite-page-title' | pandoc -f html -t plain)
        # As level_two link_from are not unique
        # We need to create link_from all unique to link_to (also unique)
        # For this we create a prefix , this will be the PascalCase of the directory
        #        i.e 
        #             Enum MimeType may be brom Base Service or from Content Service
        #             Do "Base Enum MimeType" and "Content Enum MimeType"
        prefix=$(basename "$(dirname "$level_two_file")" | awk -F"-" '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1)) substr($i,2)}} 1' OFS="")
        echo "    - &${prefix} ${link_from}&" >> ${MAIN_TOUPDATE}
    done
done

# eof eof eof eof Creating a manual index of the documentation
# -----------------------------------------------------------


# Appending topics content
# -----------------------------------------------------------
    for file in "${files_array[@]}"; do

        # Parsing level_one title and link_to different to level_two
        
        is_level_one=false
        for level_one_file in "${level_one_files_array[@]}"; do
            # level_one content title and link_to
            if [ ${file} == ${level_one_file} ]; then

                # creating link_to
                link_to=$(cat ${file} | pup -i 0 --pre 'h1.devsite-page-title' | pandoc -f html -t plain)
                echo "# ${link_to} #" >> ${MAIN_TOUPDATE}   ## Actual link_to
                echo ${link_to} | figlet >> ${MAIN_TOUPDATE}
                is_level_one=true
                break;
            fi
        done

        # level_two content title and link_to
        if [ "$is_level_one" = false ]; then
                prefix=$(basename "$(dirname "$file")" | awk -F"-" '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1)) substr($i,2)}} 1' OFS="")
                link_to="# ${prefix} $(cat ${file} | pup -i 0 --pre 'h1.devsite-page-title' | pandoc -f html -t plain) #" 
                echo ${link_to} >> ${MAIN_TOUPDATE}
        fi

        # Parsing content
        cat ${file} | pup -i 0 --pre 'article.devsite-article' | pandoc -f html -t plain >> ${MAIN_TOUPDATE}
    done
# eof eof eof  Appending topics content
# -----------------------------------------------------------

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
