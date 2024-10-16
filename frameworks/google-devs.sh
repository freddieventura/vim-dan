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

for DOWNLOAD_LINK in "${DOWNLOAD_LINKS[@]}"; do
    ntfs_filename=$(echo "${DOWNLOAD_LINK}" | sed 's/[<>:"\/\\|?*]/_/g')

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
      "${DOWNLOAD_LINK}" 2>&1 | grep '^--' | awk '{print $3}' > "${DOCU_PATH}/${ntfs_filename}.txt"
done

##      --wait=3 \
##      --random-wait \


## 2nd) Filter those links taking off undesired files

## 3rd) Perform the Index given the link-list.txt


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
