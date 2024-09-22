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
DOWNLOAD_LINK="https://nodejs.org/dist/latest-v16.x/docs/api/index.html"
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS



indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

## This is a huge directory that cannot be indexed easily
##    1st) There is no .html page with the full directory available 
##    2nd) There is a huge amount of clutter. Packages that are of no utility at all


## I have used the following to get a directory link
## https://www.npmjs.com/package/all-the-package-names
## npm i all-the-package-names
## ./node_modules/all-the-package-names/cli.js > all-npm-packages.txt
#
# 
## There are currently 2.694.866 , Close to 3 Million packages.
##
## We have to filter down by Pull Weekly Downloads
##      - Say we want all the packages that have more than 100 weeklyDowns
    
mapfile -t packages_array < /home/fakuve/downloads/vim-dan-original/npmjs/file-list/all-npm-split-aa

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59"

mapfile -t files_array < <(find ${DOCU_PATH}/file-list/ | sort )
for file in "${files_array[@]}"; do
    mapfile -t packages_array < <(cat ${file})

    for package in "${packages_array[@]}"; do
        while true; do
            # Send a request with custom user-agent header and process substitution to capture both response status code and data
            RESPONSE=$(curl -s -w "%{http_code}" --user-agent "$USER_AGENT" "https://www.npmjs.com/package/${package}" | tee >(cat > /dev/null) )

            # Extract HTTP status code from the response
            RESPONSE_CODE=${RESPONSE: -3}

            if [ "$RESPONSE_CODE" -eq 429 ]; then
                echo "Received 429 - Too Many Requests response for package $package. Waiting 1 minute..."
                sleep 60
            else
                if [ "$RESPONSE_CODE" -eq 200 ]; then
                    # Extract the string from the website
                    number_string=$(echo "$RESPONSE" | pup '._9ba9a726' | pandoc -f html -t plain)

                    # Remove commas from the string
                    number_string_without_commas=$(echo "$number_string" | tr -d ',')

                    # Convert the string to an integer using bc
                    number=$(echo "$number_string_without_commas" | bc)

                    # Check if the number is greater than 100
                    if [ "$number" -gt 100 ]; then
                        echo "$package" >> "${DOCU_PATH}/packages-more-100downs.txt"
                        if [ -n "$exit_code" ] && [ "$exit_code" -ne 0 ]; then
                            echo "An error occurred. with package $package"
                        fi
                    fi
                fi
                break
            fi
        done
    done
    echo "Finnished processing : " ${file}
done

    ## PREPARING THE FILES FOR PROCESSING
    echo "Preparing the files for processing ..."
}

parsing_rules(){
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}


mapfile -t files_array < <(find ${DOCU_PATH}/downloaded -name *.html | sort )
for file in "${files_array[@]}"; do
    ## Creating an associative array with the links_from (links_to) and their filename
    # Declare an associative array
    declare -A links_to_paths

    # Use process substitution to run both find commands simultaneously
    while IFS= read -r key && IFS= read -r value <&3; do
    # Assign the key-value pair to the associative array
    links_to_paths["$key"]="$value"
    done < <(cat ${file} | pup -i 0 --pre '#apicontent h2' | pandoc -f html -t plain |sed -e 's/[ \t]*#[ \t]*$//') \
       3< <(echo ${file})
    
done


## We need to order the documentation according to the linksFrom
## Ordering the keys in a new Array
mapfile -t sorted_links_to_paths < <(printf "%s\n" "${!links_to_paths[@]}" | sort -t = -k 1)
## Remember after this anytime we access the array
## We need to Iterate through each member of the array that correspond to the sorted keys
## When in need to retrieve the files , use the associative array


# Parsing our own index for docu
# -----------------------------------------------------------
# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}


## We need to Iterate through each member of the array that correspond to the sorted keys
for key in "${sorted_links_to_paths[@]}"; do
    parentname="$(basename "$(dirname ${links_to_paths[${key}]})")"
    link_from="& @${parentname}@ ${key} &"
    echo "- ${link_from}" >> ${MAIN_TOUPDATE}
done

# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu

echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK

# Parsing each manpage
# -----------------------------------------------------------
## We need to Iterate through each member of the array that correspond to the sorted keys
for key in "${sorted_links_to_paths[@]}"; do
    ## Creating Link_to
    parentname="$(basename "$(dirname ${links_to_paths[${key}]})")"
    echo "# ${parentname} ${key} #" >> ${MAIN_TOUPDATE}
    echo ${key} | figlet  >> ${MAIN_TOUPDATE}

    ## When in need to retrieve the files , use the associative array
    cat ${links_to_paths[${key}]} | pup -i 0 --pre 'details' | pandoc -f html -t plain | sed -e 's/[ \t]*#[ \t]*$//' >> ${MAIN_TOUPDATE}
    cat ${links_to_paths[${key}]} | pup -i 0 --pre '#apicontent' | pandoc -f html -t plain | sed -e 's/[ \t]*#[ \t]*$/#/' >> ${MAIN_TOUPDATE}
    echo "" >> ${MAIN_TOUPDATE}  ## ADDING A LINE BREAK
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
