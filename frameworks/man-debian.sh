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
DOWNLOAD_LINK="https://manpages.debian.org/contents-bookworm.html"
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
      -nH \
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
      --include="bookworm,bookworm/*" \
      --accept '*.html,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}
      

    ## Removing duplicates and other clutter
    find ${DOCU_PATH}/downloaded -not -path "${DOCU_PATH}/downloaded/bookworm/*" -delete
    find ${DOCU_PATH}/downloaded -type f -name 'index.html' -delete

    ## Removing other languages other than english
    find . -type f \( -name "*.html" ! -name "*en.html" \) -exec rm {} \;
    find ${DOCU_PATH}/downloaded -type f \( -name "*.html" ! -name "*en.html" \) -exec rm {} \;


# ALGORITHM TO DELETE SAME HEADER FILES
# -------------------------------------------------
for dir in "$DOCU_PATH"/downloaded/bookworm/*/; do
    mapfile -td '' files < <(find "$dir" -type f -name '*' -print0)

    if (( "${#files[@]}" > 1 )); then
        for file in "${files[@]}"; do

            title=$(pup .head-ltitle < "$file")

            for fileb in "${files[@]}"; do
                if [[ $file != "$fileb" ]]; then

                    if [[ $title == "$(pup .head-ltitle < "$fileb")" ]]; then
                        printf 'progname: Removing Duplicate: %s\n' "$fileb"
                        rm -f -- "$fileb"
                    fi
                fi
            done
        done
    fi
done
# EOF EOF EOF ALGORITHM TO DELETE SAME HEADER FILES
# -------------------------------------------------

    ## Because this documentation is really big
    ## Need to split files into different docu sections
            ##    Section 1: 0-9  and A to E
            ##    Section 2: F to J
            ##    Section 3: K to O
            ##    Section 4: P to T
            ##    Section 5: U to Z
    echo "Splitting files into different docu sections ..."
    [ ! -d "${DOCU_PATH}/../man-debiane/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debiane/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[0-9A-Ea-e]* ${DOCU_PATH}/../man-debiane/downloaded/
    [ ! -d "${DOCU_PATH}/../man-debianj/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debianj/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[F-Jf-j]* ${DOCU_PATH}/../man-debianj/downloaded/
    [ ! -d "${DOCU_PATH}/../man-debiano/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debiano/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[K-Ok-o]* ${DOCU_PATH}/../man-debiano/downloaded/
    [ ! -d "${DOCU_PATH}/../man-debiant/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debiant/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[P-Tp-t]* ${DOCU_PATH}/../man-debiant/downloaded/
    [ ! -d "${DOCU_PATH}/../man-debianz/downloaded/" ] && mkdir -p "${DOCU_PATH}/../man-debianz/downloaded/"
    mv ${DOCU_PATH}/downloaded/bookworm/[U-Zu-z]* ${DOCU_PATH}/../man-debianz/downloaded/
}

parsing_rules(){
##    echo "ERROR !!"
##    echo "This documentation is not to be parsed. Refer to ./vim-dan.sh man-debian[ejotz] -p"
    # Header of docu    
    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}



# Parsing our own index for docu
# -----------------------------------------------------------
# This will be the linkFrom items
echo "index" | figlet >> ${MAIN_TOUPDATE}


mapfile -t files_array < <(find ${DOCU_PATH}/downloaded/ -type f | awk '{print gsub(/\//,"/")"|"$0; }' | sort -t'|' -k1,1n -k2 | sed 's/^[^|]*|//')

for file in "${files_array[@]}"; do
    link_from="& $(cat ${file} | pup -i 0 --pre '.head-ltitle' | pandoc -f html -t plain) &"
    echo "- ${link_from}" >> ${MAIN_TOUPDATE}
done
# -----------------------------------------------------------
# eof eof eof Parsing our own index for docu

# TROUBLESHOOTING
# TROUBLESHOOTING
##for file in "${files_array[@]}"; do
##    echo "$file"
##    ((count++))
##    if [ "$count" -eq 20 ]; then
##        break
##    fi
##done
# TROUBLESHOOTING
# TROUBLESHOOTING


# Parsing each manpage
# -----------------------------------------------------------
for file in "${files_array[@]}"; do

    ## Creating Link_to
    echo "# $(cat ${file} | pup -i 0 --pre '.head-ltitle' | pandoc -f html -t plain) #" >> ${MAIN_TOUPDATE} 

    cat ${file} | pup -i 0 --pre 'div.manual-text' | pandoc -f html -t plain  >> ${MAIN_TOUPDATE} 
done
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
