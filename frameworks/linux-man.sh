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
DOWNLOAD_LINK="https://manned.org/"
# -------------------------------------
# eof eof eof DECLARING VARIABLES AND PROCESSING ARGS


indexing_rules(){
    if [ ! -d "${DOCU_PATH}/downloaded" ]; then
        mkdir -p "${DOCU_PATH}/downloaded"
    fi

## Preparing a package list with most relevant linux packages
## ----------------------------------------------------------
####wget \
####    `## Directory Options` \
####    --directory-prefix=${DOCU_PATH}/ \
####    https://popcon.debian.org/main/by_inst
####
##### Cleaning top and bottom lines
####sed -n '/^1/,$p' ${DOCU_PATH}/by_inst > tmpfile && mv tmpfile ${DOCU_PATH}/by_inst
####sed -i '/^-*$/,$d' ${DOCU_PATH}/by_inst
##### Grabbing the packages with 15 or more Installations
####gawk -i inplace '$3 >= 14 { print $2 }' ${DOCU_PATH}/by_inst
####
###### eof preparing a package-list
###### -----------------------
####
####
###### Preparing a url-list.txt
###### -----------------------
####url_site="https://manned.org"
####USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59"
####mapfile -t packages_array < <(cat ${DOCU_PATH}/by_inst)
####
####for package in "${packages_array[@]}"; do
####
####    RESPONSE=$(curl -s --include -w "%{http_code}" --user-agent "$USER_AGENT" "https://manned.org/browse/search?q=${package}" | tee >(cat > /dev/null) )
####    RESPONSE_CODE="${RESPONSE: -3}"
####
####    if [ "$RESPONSE_CODE" -eq 429 ]; then
####        echo "Received 429 - Too Many Requests response for package $package. Waiting 1 minute..."
####        sleep 60
####    else
####        if [ "$RESPONSE_CODE" -eq 200 ]; then
####            # Extract the string from the response parse it and store it
####            full_urls=$(echo "$RESPONSE" | pup 'body ul li a' | sed -n 's/.*href="\([^"]*\)".*/\1/p' | sed "s|^|${url_site}|")
####            echo ${full_urls} >> "${DOCU_PATH}/url-list.txt"
####        elif [ "$RESPONSE_CODE" -eq 307 ]; then
####            # Extract from the response headers , the string corresponding to location:
####            echo "$RESPONSE" | awk '/^Location: / {print $2}' >> "${DOCU_PATH}/url-list.txt"
####        fi
####    fi
####
#### 
####done
####
###### Preparing for processing url-list.txt
##### Removing whitspaces
####sed -i '/^\s*$/d' ${DOCU_PATH}/url-list.txt
##### Separating words (whitespace separated strings) into new lines
####sed -i 's/ /\n/g' ${DOCU_PATH}/url-list.txt
##### Removing duplicates file-inplace
####awk '!seen[$0]++' ${DOCU_PATH}/url-list.txt > ${DOCU_PATH}/tmpfile && mv ${DOCU_PATH}/tmpfile ${DOCU_PATH}/url-list.txt ${DOCU_PATH}/url-list.txt


## eof eof eof efo  eof Preparing a url-list.txt
## ----------------------------------------------------------


## Downloading url-list.txt , as long as there is free space
## Halt and prompt user to perform action upon not available space
## ---------------------------------------------------------------------
remote_ip="10.7.0.3"

# Function to check disk space
check_disk_space() {
    if [ $(df | awk '$1 == "/dev/vda1" {print $4}') -gt 102400 ]; then
        echo "There is enough space."
    else
        echo "Moving chunk of files to remote drive on ${remote_ip} freeing up space on VPS"
        rsync -av --remove-source-files -e "ssh -p 8022" ${DOCU_PATH}/downloaded/ ${remote_ip}:/data/data/com.termux/files/home/downloads/vim-dan-original/linux-man/downloaded/
    fi
}

# Counter for downloaded files
downloaded_files=0

while read -r url; do
    # Check disk space every 150 files
    if [ $((downloaded_files % 150)) -eq 0 ]; then
        check_disk_space
    fi

    ## MAIN DOWNLOAD COMMAND
    wget \
    `## Basic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
    `## Download Options` \
      --timestamping \
      --waitretry=40 \
    `## Directory Options` \
      -nH \
      --directory-prefix=${DOCU_PATH}/downloaded \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
      --content-disposition \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
    `## Recursive Accept/Reject Options` \
      ${url}
    ## EOF EOF EOF EOF EOF MAIN DOWNLOAD COMMAND

    # Increment downloaded files counter
    ((downloaded_files++))
done < ${DOCU_PATH}/url-list.txt
## eof eof eof Downloading url-list.txt , as long as there is free space
## ---------------------------------------------------------------------



}

parsing_rules(){
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
    done < <(cat ${file} | pandoc -f html -t plain | grep -A2 'pdf' | head -n 3 | tail -n 1) \
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
    link_from="& ${key} &"
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
    echo "# ${key} #" >> ${MAIN_TOUPDATE} 
    echo ${key} | figlet  >> ${MAIN_TOUPDATE} 

    ## When in need to retrieve the files , use the associative array
    cat ${links_to_paths[${key}]} | pup -i 0 --pre 'div#manpage' | pandoc -f html -t plain  >> ${MAIN_TOUPDATE} 
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
