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
DOCU_NAME='zaproxy'
MAIN_TOUPDATE="${DOCU_PATH}/${DOCU_NAME}.javadocdan"
DOWNLOAD_LINK="https://javadoc.io/doc/org.zaproxy/zap/latest/index.html"
PARSED_LINK=$(node $CURRENT_DIR/../scripts/javadocGetJarLink.js ${DOWNLOAD_LINK})
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS



indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

    wget --directory-prefix=${DOCU_PATH}/downloaded ${PARSED_LINK}
    filename=$(basename ${PARSED_LINK})
    unzip ${DOCU_PATH}/downloaded/${filename} -d ${DOCU_PATH}/downloaded/
    rm ${DOCU_PATH}/downloaded/${filename}     

}

arranging_rules(){


## Making a backup
cp -r ${DOCU_PATH}/downloaded/ ${DOCU_PATH}/downloaded-bk/

## Cleaning up documents

## Removing everything but the actual object files
rm -r ${DOCU_PATH}/downloaded/jquery
rm -r ${DOCU_PATH}/downloaded/legal
rm -r ${DOCU_PATH}/downloaded/META-INF
rm -r ${DOCU_PATH}/downloaded/resources

find ${DOCU_PATH}/downloaded -maxdepth 1 -type f -delete



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

mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort )


## First create the title array
title_array=()
for file in "${files_array[@]}"; do

    # (Multi-rule) Parsing functions , add as many as you want
    f1() { pup -i 0 --pre '.title' | pandoc -f html -t plain | sed ':a;N;$!ba;s/\n/ /g';}

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


#for file in "${files_array[@]}"; do
#    echo "file : ${file}" >&2 ## DEBUGGING
#done
#
#
#for path in "${paths_linkto[@]}"; do
#    echo "path : ${path}" >&2 ## DEBUGGING
#done


# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}


# Populate dirs_array with space-separated strings
for file in "${files_array[@]}"; do

    filename=$(basename  "${file}" .html)
    ## Splitting the dirs from the filename , putting all of them into dirs_array
    remaining_file="${filename}"

#echo "filename : ${filename}" >&2 ## DEBUGGING
#echo "remaining_file : ${remaining_file}" >&2 ## DEBUGGING

    for ((i=0; i< 25; i++)); do
        if [[ "$remaining_file" =~ ([^\)]+)-\)(.+) ]]; then
            dirs_array[i]="${BASH_REMATCH[1]}"
            remaining_file="${BASH_REMATCH[2]}"

#echo "dirs_array : ${dirs_array[@]}" >&2 ## DEBUGGING
#echo "reimaining_file : ${reimaining_file}" >&2 ## DEBUGGING
#read -p "Press enter to continue to the next step..."
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
    f1() { pup -i 0 --pre 'main' | pandoc -f html -t plain --wrap=none;}

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
    sed -e '/^\[\]$/d' \
        -e "s/$(echo -ne '\u200b')//g" \
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
