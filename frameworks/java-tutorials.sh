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
DOWNLOAD_LINK="https://docs.oracle.com/javase/tutorial/"
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
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=4 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject '*.java,*.sql,*.jar,*.jpg,*.zip,*.GIF,*mp4,*.gif,*.svg,*.js,*json,*.css,*.PNG,*.png,*.xml,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}
}

arranging_rules(){


## Making a backup
cp -r ${DOCU_PATH}/downloaded ${DOCU_PATH}/downloaded-bk


## Unesting Documentation
##mv ${DOCU_PATH}/downloaded/docs.oracle.com/javase/tutorial/* ${DOCU_PATH}/downloaded/
##rm -r ${DOCU_PATH}/downloaded/docs.oracle.com/
##
#### Removing first level files
##find "${DOCU_PATH}/downloaded/" -maxdepth 1 -type f -delete


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


## DEESTRUCTURING THE DIRECTORY TREE
## ------------------------------------------------------------------------
## Search on a dir, place the files nested in a subdir, on the dir below
## Rename them to ${subdir}file.ext

## For instance check in
## www.zaproxy.org/docs/desktop/addons/
##
## there is gonna be files such as 
## www.zaproxy.org/docs/desktop/addons/access-control-testing/contextoptions.html
##
## make it 
## www.zaproxy.org/docs/desktop/addons/access-control-testing-contextoptions.html



# De-estructure all the directory hierarchy
for i in {1..15}; do

    mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -mindepth 2 -type f)

    for file in "${files_array[@]}"; do
        parent="$(basename "$(dirname ${file})")"
        dirname=$(dirname ${file})
        mv ${file} "$dirname/../"${parent}"-)$(basename ${file})";
    done

done

# Pruning off the empty directories
find "${DOCU_PATH}/downloaded/" -type d -empty -delete
## EOF EOF EOF DEESTRUCTURING THE DIRECTORY TREE
## ------------------------------------------------------------------------




}


parsing_rules(){

    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from :" >> ${MAIN_TOUPDATE}
    echo " - ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
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

mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort -V )


## First create the title array
title_array=()
for file in "${files_array[@]}"; do

    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'div#PageTitle' | pandoc -f html -t plain | sed ':a;N;$!ba;s/\n/ /g';}

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


##for file in "${files_array[@]}"; do
##    echo "file : ${file}" >&2 ## DEBUGGING
##done
##
##
##for path in "${paths_linkto[@]}"; do
##    echo "path : ${path}" >&2 ## DEBUGGING
##done


# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}


# Populate dirs_array with space-separated strings
for file in "${files_array[@]}"; do

    filename=$(basename  "${file}")
    ## Splitting the dirs from the filename , putting all of them into dirs_array
    remaining_file="${filename}"

##echo "filename : ${filename}" >&2 ## DEBUGGING

    for ((i=0; i< 25; i++)); do
        if [[ "$remaining_file" =~ ([^\)]+)-\)(.+) ]]; then
            dirs_array[i]="${BASH_REMATCH[1]}"
            remaining_file="${BASH_REMATCH[2]}"
        else
            dirs_array[i]="${remaining_file}"
            break
        fi
    done

#echo "exiting and processing file"
##echo "Exiting dirs_array : ${dirs_array[@]}" >&2 ## DEBUGGING

    ## In order to create from this
    ##"workspace-)cse-)reference-)wrap"
    ##"workspace-)cse-)reference-)wrap-private-key"
    ##"workspace-)events-)docs-)release-notes"
    ##
    ## to this
    ##- workspace
    ##    - cse
    ##        - reference
    ##            - wrap
    ##            - wrap-private-key
    ##    - events
    ##        - docs
    ##            -release-notes
    ##
    ## We need to check dirs_array member by member and see what is the indentation
    ## index in which the directory structure differs
    ##
    ##
    ## defining dirs_arrays
    ## defining prev_dirs_array
    ##      Comparing them we calculate
    ##      first_discrepancy_level 
    ##          the nesting level at which dirst_array and prev_dirs_array differ
    ##
    ## for instance          
    ##     prev_dirst_array=( "workspace" "cse" "reference" "wrap-private-key") 
    ##     dirs_array=( "workspace" "events" "docs" "release-notes") 
    ##     first_discrepancy_level=2
    ## knowing that file_nesting_level will be determined by length of dirs_array
    ##   file_nesting_level=${#dirs_array[@]} 
    ##
    ## And having 3 printing expressions
    ##
    ##
    ## # printing indentation tabs for a certain current_nesting_level
    ## for ((i=1 ; i<=${current_nesting_level}; i++)); do
    ##     for ((j=1; j<${i}; j++)); do
    ##         echo -ne "\t" >> ${MAIN_TOUPDATE}
    ##     done
    ## done
    ##
    ## # printing a linkto bulletpoint
    ## echo -ne "- & @${filename}@ ${paths_linkto[${file}]} &\n" >> ${MAIN_TOUPDATE}
    ##
    ## # printing a subdir bullet point
    ## echo -ne "- ${dirs_array[(${current_nesting_level})]}\n" >> ${MAIN_TOUPDATE}
    ##
    ## Iterating on the filelist
    ##     calculate first_discrepancy_level for each dirs_array in compare with prev_dirs_array
    ## Then for each file we will need to be iterating on each current_nesting_level
    ## # Provided that file_nesting_level=${#dirs_array[@]}
    ##      we iterate from first_discrepancy_level to file_nesting_level
    ##      setting each iteration as current_nesting_level
    ##      Starting from current_nesting_level=first_discrepancy_level
    ##      # printing indetation tabs for a certain current_nesting_level
    ##          if indentantion_nesting_level -eq to file_nesting_level
    ##          then we 
    ##          # printing a linkto bulletpoint
    ##          otherwise
    ##          # printing a subdir bullet point
    ## Note: Base of index variables
    ##  first_discrepancy_level , base 0
    ##  file_nesting_level , base 1 , (converting to base 0)



    # Compare elements

    for ((i=0; i<${#dirs_array[@]}; i++)); do
        if [ "${dirs_array[$i]}" != "${prev_dirs_array[$i]}" ]; then
            first_discrepancy_level=${i}
            break
        fi
    done

##echo "prev_dirs_array : ${prev_dirs_array}" >&2 ## DEBUGGING
##echo "prev_dirs_array length : ${#prev_dirs_array[@]}" >&2 ## DEBUGGING
##echo "dirs_array : ${dirs_array}" >&2 ## DEBUGGING
##echo "first_discrepancy_level : ${first_discrepancy_level}" >&2 ## DEBUGGING


    # For the rest we will need to be iterating on each current_nesting_level
    # Provided that file_nesting_level=${#dirs_array[@]}
    file_nesting_level=${#dirs_array[@]}
    # converting to base 0
    file_nesting_level=$((file_nesting_level - 1))


    # we iterate from first_discrepancy_level to file_nesting_level
    # setting each iteration as current_nesting_level
    for ((current_nesting_level=${first_discrepancy_level} ; current_nesting_level<=${file_nesting_level}; current_nesting_level++)); do


    # printing indetation tabs for a certain current_nesting_level
        # printing indentation tabs for a certain current_nesting_level
        for ((i=0 ; i<=${current_nesting_level}; i++)); do
            for ((j=0; j<${i}; j++)); do
                echo -ne "\t" >> ${MAIN_TOUPDATE}
            done
        done

##echo "file_nesting_level : ${file_nesting_level}" >&2 ## DEBUGGING
##echo "current_nesting_level : ${current_nesting_level}" >&2 ## DEBUGGING
##read -p "Press enter to continue to the next step..." ## DEBUGGING



        # if indentantion_nesting_level -eq to file_nesting_level
        # then we print the linkto bulletpoint
        # otherwise we print the subdir bulletpoint
            if [[ ${current_nesting_level} -eq ${file_nesting_level} ]]; then
            # printing a linkto bulletpoint
            echo -ne "- & @${filename}@ ${paths_linkto[${file}]} &\n" >> ${MAIN_TOUPDATE}
        else
            # printing a subdir bullet point
#echo "dirs_array[${current_nesting_level}] : ${dirs_array[(${current_nesting_level})]}" >&2 ## DEBUGGING
            echo -ne "- ${dirs_array[(${current_nesting_level})]}\n" >> ${MAIN_TOUPDATE}
        fi
    done

        
    ## Settings arrays for a new file iteration
    unset prev_dirs_array
    prev_dirs_array=("${dirs_array[@]}")
    unset dirs_array
done


echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK

# Parsing and appending content , using Multi-rule
# -----------------------------------------------------------
## We need to Iterate through each member of the array that correspond to the sorted keys
for path in "${files_array[@]}"; do
    ## Creating Link_to
    filename=$(basename  "${path}")
    echo "# ${filename} #" >> ${MAIN_TOUPDATE}
    echo "& ${paths_linkto[${path}]} &" >> ${MAIN_TOUPDATE}

    echo ${paths_linkto[${path}]} | figlet  >> ${MAIN_TOUPDATE}


    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'div#PageContent' | pandoc -f html -t plain --wrap=none;}

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
       cat ${path} | pandoc -f html -t plain --wrap=none > "$content_dump"
    fi

    ## Retrieving content of the files and cleaning it
    sed -e  's/^[^|]*|//' \
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
