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
https://developers.google.com/
)
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS



indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

## 1st) Run a spider the whole website to get a list will all the links

declare -a links_files
for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
    links_file=$(echo "${DOWNLOAD_LINK}" | sed 's/[<>:"\/\\|?*]/_/g')
    links_files+=("${links_file}")
    wget \
    `## Basic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
      --force-html \
    `## Download Options` \
      --spider \
    `## Directory Options` \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=inf \
      --delete-after \
    `## Recursive Accept/Reject Options` \
      "${DOWNLOAD_LINK}" 2>&1 | grep '^--' | awk '{print $3}' > "${DOCU_PATH}/${links_file}.txt"
done

##      --wait=3 \
##      --random-wait \


## 2nd) Filter those links taking off undesired files

for links_file in "${links_files[@]}"; do

DOCU_PATH="."
##links_file="https___shopify.dev.txt"
links_file="https___www.mongodb.com"

    ## Removing duplicates
    sort "${DOCU_PATH}/${links_file}.txt" | uniq > temp_file.txt && mv temp_file.txt "${DOCU_PATH}/${links_file}.txt"

    # Remove from other hosts links
    ## Despite no span hosts wget gives you some clutter
    common_host=$(sed -n 's|^\(https://[^/]*\).*|\1|p' "${DOCU_PATH}/${links_file}.txt" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
    sed -i "\\|${common_host}|! d" "${DOCU_PATH}/${links_file}.txt"

    ## Clean urls with query strings (the ones with ? and %)
    sed -i "/\?\|&\|\%/d" "${DOCU_PATH}/${links_file}.txt"
    
    ## Keep only  - non-extension urls (they are html)
    ##            - .html 
    sed -n -i -E '/\/[^.\/]+$|\/.*\.html$/p' "${DOCU_PATH}/${links_file}.txt"

    ## We transform the files to csv
    ## Using 9 as not to collide with exit status of wget
    sed -i 's/$/,-1/' "${DOCU_PATH}/${links_file}.txt"
    sed -i '1s/^/url,exit_status\n/' "${DOCU_PATH}/${links_file}.txt"
    mv "${DOCU_PATH}/${links_file}.txt" "${DOCU_PATH}/${links_file}.csv"

done


## 3rd) Perform the Index given the files_links.csv


## Some of this indexes are huge , would take days even weeks to process
## We can reduce this by splitting the task into 4 wget processes that wont collide
##      - The firstone can start from the top row
##      - Secondone can start from the bottom row
##      - Thirdone starting from half entry onwards 
##      - Fourthone starting from half entry backwards
##  Each process will record in their own files_links.csv 
##      - Upon successfully downloading a file , second columnd ,1
##       i.e :
##             - https://shopify.dev/tools/cli,1
##             - https://shopify.dev/tutorials/refund-shipping-duties,0


concurrent_index() {

## It will perform wget download of a file_list.csv
## This file_list is of the form url,downloaded
##       i.e :
##             - https://shopify.dev/tools/cli,1
##             - https://shopify.dev/tutorials/refund-shipping-duties,0
##  First parameter no_splits
##  Second parameter this_split
##  Third parameter master_split_ip
##  Fourth parameter dump_chunks_size
##  
##  The algorithm separates the file_list.csv , into a no of splits no_splits 
##      They have to be even
##              If one split this process will download from top to bottom from the first file
##
##              If two splits         Direction        , StartingFile
##                  - this_split=1  from top to bottom , first file
##                  - this_split=2  from bottom to top ,  last file
##
##              If no_splits=4
##                  - this_split=1  from top to bottom , first file
##                  - this_split=2  from bottom to top ,  last file
##                  - this_split=3  from top to bottom ,  file no 1/2 of length
##                  - this_split=4  from bottom to top ,  file no 1/2 of length
##
## This algorithm is designed this way so we can add more hosts without having to start the process again
##      For instance if you decide to start the index with no_splits=1 , 
##          then after some hours you decide to add otherone, you will be able to and wont collide
##
##       The same if you want to grow from no_splits=2 to no_splits=4 , etc...
##
## Understanding that this_split=1 , is the master_split
##      This process will guide all the indexing process, gathering eventually
## This concurrent download can be monitored manually.
## Meaning a sysadmin will monitor each process, stopping them manually
##
## Although if specified with master_split_ip , each slave_split (all except split_no=1) will
##      report their state of their download to master_split , and when colliding , process will stop
## If specified dump_chunks_size , then that slave_split , will halt the download as soon as its stored space has reached that chunk_size , and will transfer it to master_split .
##       As soon as it is transfered that chunk, the download will resume
       

    declare -a urls
    declare -a is_downloaded

    # Read the CSV file
    while IFS=',' read -r url downloaded; do
        # Skip the header
        if [[ "$url" != "url" ]]; then
            # Add values to arrays
            urls+=("$url")
            is_downloaded+=("$downloaded")
        fi
    done < "${DOCU_PATH}/${links_file}.csv"


    for (( i = 0 ; ${i} <= ${#url[@]} ; i++ )); do


    done


for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
    wget \
    `##tBasic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
      --rejected-log=${DOCU_PATH}/rejected.log \
    `## Download Options` \
      --timestamping \
      --restrict-file-names=windows \
    `## Directory Options` \
      --nH \
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

}


arranging_rules() {

##### THIS INDEXED DOCUMENTATION IS BIG 20 GB 
##### Good to split it in different parts produts
###
##### Making a backup
###cp -r "${DOCU_PATH}/downloaded" "${DOCU_PATH}/downloaded-bk"
###
###
##### RENAME LONE INDEX.HTML
##### ------------------------------------------------------------------------
##### Rename lone index.html to subdir folder and place this file a level down
##### For instance
##### www.zaproxy.org/docs/alerts/
##### www.zaproxy.org/docs/alerts/0/index.html
##### should become
##### www.zaproxy.org/docs/alerts/0.html
###
###
###mapfile -t files_array < <(find "${DOCU_PATH}/downloaded/" -type f -name "index.html")
###for file in "${files_array[@]}"; do
###    parent="$(basename "$(dirname ${file})")"
###    dirname=$(dirname ${file})
###    ext=${file##*.}
###    mv ${file} "$dirname/../$parent.$ext";
###done
###
##### EOF EOF EOF RENAME LONE INDEX.HTML
##### ------------------------------------------------------------------------
###
#### Remove the files that are at depth 1 (they are not explicative)
###find "${DOCU_PATH}/downloaded/" -maxdepth 1 -type f -exec rm -f {} +
###
#### Pruning off the empty directories
###find "${DOCU_PATH}/downloaded/" -type d -empty -delete
###

## Selecting Splits
## We are going to split-out from here

# Get all the directories in the current path and sort them by size in MB
#find . -type d -maxdepth 1 -exec du -sm {} \; | sort -rn
#  19940	.
#  11679	./google-ads 
#  3343	./android 
#  1822	./search 
#  700	./static  (DELETE)
#  410	./apps-script 
#  396	./gmail 
#  379	./ar 
#  276	./drive
#  198	./admin-sdk
#  (...)
# 120 subdirs in total

# there are many smalls subdirs
# We are going to split-out bigones such as


VIMDAN_DIR="$(readlink -f ${DOCU_PATH}/..)"
[ ! -d ${VIMDAN_DIR}/google-devs-ads/downloaded ] && mkdir -p ${VIMDAN_DIR}/google-devs-ads/downloaded
mv ${DOCU_PATH}/downloaded/google-ads ${VIMDAN_DIR}/google-devs-ads/downloaded/

[ ! -d ${VIMDAN_DIR}/google-devs-android/downloaded ] && mkdir -p ${VIMDAN_DIR}/google-devs-android/downloaded
mv ${DOCU_PATH}/downloaded/android ${VIMDAN_DIR}/google-devs-android/downloaded/

[ ! -d ${VIMDAN_DIR}/google-devs-search/downloaded ] && mkdir -p ${VIMDAN_DIR}/google-devs-search/downloaded
mv ${DOCU_PATH}/downloaded/search ${VIMDAN_DIR}/google-devs-search/downloaded/

[ ! -d ${VIMDAN_DIR}/google-devs-appscript/downloaded ] && mkdir -p ${VIMDAN_DIR}/google-devs-appscript/downloaded
mv ${DOCU_PATH}/downloaded/apps-script ${VIMDAN_DIR}/google-devs-appscript/downloaded/



# PENDING PENDING PENDING PENDING
# PENDING PENDING PENDING PENDING
# PENDING PENDING PENDING PENDING
# REDOING THE INDEX AS NOT ALL HAS BEEN GRABBED


# Find all the directories that have either a ./docs/ subdir or ./docs.html , the rest delete them
# ---------------------------------------------------------------------------
# Path to the parent directory
PARENT_DIR="${DOCU_PATH}/downloaded/"

# Find all subdirectories
find "$PARENT_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r DIR; do
    # Check if the directory contains 'docs' or 'docs.html'
    if ! find "$DIR" -type d -name "docs" -print -quit | grep -q '.' &&
       ! find "$DIR" -type f -name "docs.html" -print -quit | grep -q '.'; then
        # If neither 'docs' nor 'docs.html' is found, delete the directory
        echo "Deleting directory: $DIR"
        rm -rf "$DIR"
    fi
done
# ---------------------------------------------------------------------------





###### DEESTRUCTURING THE DIRECTORY TREE
###### ------------------------------------------------------------------------
###### Search on a dir, place the files nested in a subdir, on the dir below
###### Rename them to ${subdir}file.ext
####
###### For instance check in
###### www.zaproxy.org/docs/desktop/addons/
######
###### there is gonna be files such as 
###### www.zaproxy.org/docs/desktop/addons/access-control-testing/contextoptions.html
######
###### make it 
###### www.zaproxy.org/docs/desktop/addons/access-control-testing-contextoptions.html
####
####
####
##### De-estructure all the directory hierarchy
####for i in {1..15}; do
####
####    mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -mindepth 2 -type f)
####
####    for file in "${files_array[@]}"; do
####        parent="$(basename "$(dirname ${file})")"
####        dirname=$(dirname ${file})
####        mv ${file} "$dirname/../"${parent}"-)$(basename ${file})";
####    done
####
####done
####
##### Pruning off the empty directories
####find "${DOCU_PATH}/downloaded/" -type d -empty -delete
###### EOF EOF EOF DEESTRUCTURING THE DIRECTORY TREE
###### ------------------------------------------------------------------------


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

mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort -V )


## First create the title array
title_array=()
for file in "${files_array[@]}"; do

    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'h1.devsite-page-title' | pandoc -f html -t plain | sed ':a;N;$!ba;s/\n/ /g';}  ## --> MODIFY THIS
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

# Populate dirs_array with space-separated strings
for file in "${files_array[@]}"; do

    filename=$(basename  "${file}" .html)
    ## Splitting the dirs from the filename , putting all of them into dirs_array
    remaining_file="${filename}"
    for ((i=0; i< 25; i++)); do
        if [[ "$remaining_file" =~ ([^\)]+)-\)(.+) ]]; then
            dirs_array[i]="${BASH_REMATCH[1]}"
            remaining_file="${BASH_REMATCH[2]}"
        else
            dirs_array[i]="${remaining_file}"
            break
        fi
    done


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
    ## and at that level create a new bullet point
    ## for instance in between
    ## "workspace-)cse-)reference-)wrap-private-key"
    ## "workspace-)events-)docs-)release-notes"
    ## It differs at level 1 (assuming nesting_index_differ is based 0)


    # Compare elements
    
    for ((i=0; i<${#dirs_array[@]}; i++)); do
        if [ "${dirs_array[$i]}" != "${prev_dirs_array[$i]}" ]; then
            nesting_index_differ=${i}
            break
        fi
    done

    ## Creating index bullet point
    
    ## Checking if it is not the first file found
    if [[ ${#prev_dirs_array} -gt 0 ]]; then


        if [[ ${nesting_index_differ} -ne $((${#dirs_array[@]} - 1)) ]]; then
            for ((i=(${nesting_index_differ}+1); i<=${#dirs_array[@]}; i++)); do

                ## print tab for each level after one
                for ((j=1; j<${i}; j++)); do
                    echo -ne "\t" >> ${MAIN_TOUPDATE}
                done
                ## If its the lastone nesting level (file) print the whole file name
                if [[ $i -eq $((${#dirs_array[@]})) ]]; then
                    echo -ne "- & @${filename}@ ${paths_linkto[${file}]} &\n" >> ${MAIN_TOUPDATE}
                ## If not print the directory
                else
                    echo -ne "- ${dirs_array[(i - 1)]}\n" >> ${MAIN_TOUPDATE}
                fi

            done
        else    ## Case that we differ on the last nesting level (ergo filename)

            ## Iterating on each nesting level
            for ((i=1; i<=${#dirs_array[@]}; i++)); do
                ## If its the lastone nesting level (file) print the whole file name
                if [[ $i -eq $((${#dirs_array[@]})) ]]; then
                    echo -ne "- & @${filename}@ ${paths_linkto[${file}]} &\n" >> ${MAIN_TOUPDATE}
                ## If not add indentation
                else 
                    for ((j=1; j<${i}; j++)); do
                        echo -ne "\t" >> ${MAIN_TOUPDATE}
                    done
                fi
            done


        fi 


    ## Case that is the first file found
    else 
        
        ## Iterating on each nesting level
        for ((i=1; i<=${#dirs_array[@]}; i++)); do

            ## print tab for each level after one
            for ((j=1; j<${i}; j++)); do
                echo -ne "\t" >> ${MAIN_TOUPDATE}
            done
            ## If its the lastone nesting level (file) print the whole file name
            if [[ $i -eq $((${#dirs_array[@]})) ]]; then
                echo -ne "- & @${filename}@ ${paths_linkto[${file}]} &\n" >> ${MAIN_TOUPDATE}
            ## If not print the directory
            else
                echo -ne "- ${dirs_array[(i - 1)]}\n" >> ${MAIN_TOUPDATE}
            fi
        done

    fi

    ## Copying the rolling directory hierarcy
    unset prev_dirs_array
    prev_dirs_array=("${dirs_array[@]}")

done 


echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK

# Parsing and appending content , using Multi-rule
# -----------------------------------------------------------
## We need to Iterate through each member of the array that correspond to the sorted keys
for path in "${files_array[@]}"; do
#    ## Creating Link_to

    ## Creating Link_to
    filename=$(basename  "${path}" .html)
    echo "# ${filename} #" >> ${MAIN_TOUPDATE}
    echo "& ${paths_linkto[${path}]} &" >> ${MAIN_TOUPDATE}

    echo ${paths_linkto[${path}]} | figlet  >> ${MAIN_TOUPDATE}


    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre 'article div.devsite-article-body' | pandoc -f html -t plain --wrap=none;} ## --> MODIFY THIS

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
    sed -e '/^\[\]$/d' \ ## --> MODIFY THIS
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
