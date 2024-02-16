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
DOWNLOAD_LINK="https://docs.oracle.com/en/java/javase/17/docs/api/index.html"
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
      -nH --cut-dirs=6 \
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
      --reject '*mp4,*.gif,*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      --page-requisites \
      ${DOWNLOAD_LINK}
}

parsing_rules(){

    echo "vim-dan" | figlet -f univers > ${MAIN_TOUPDATE}
    echo ${DOCU_NAME} | figlet >> ${MAIN_TOUPDATE}
    echo "Documentation indexed from : ${DOWNLOAD_LINK} " >> ${MAIN_TOUPDATE}
    echo "Last parsed on : $(date)" >> ${MAIN_TOUPDATE}

    # 1) Parsing the Package Index
    # This is a bullet list with all the link_from
    echo "Package Index" | figlet >> ${MAIN_TOUPDATE}
    mapfile -t link_from_array < <(cat ${DOCU_PATH}/downloaded/overview-tree.html | pup -i 0 --pre 'div.header li' | pandoc -f html -t plain | sed 's/ ,//g' | sed '/^$/d')

    for link_from in "${link_from_array[@]}"; do
        echo "- &${link_from}&" >> ${MAIN_TOUPDATE} 
    done


    # 2) Precaching each Package Tree
    # To each link_from such as - |com.sun.management|
    #       has a correspondence to a certain package=tree.html
    #                   such as - 
    #  .//downloaded/jdk.management/com/sun/management/package-tree.html
    #  We need to iterate through each package-tree.html , and find its signature
    #  Creating an associative array ([packageSignature01]="treePath01" [pacakgeSignature02]="treePath02")

    # Declare an associative array
    declare -A sig_to_paths

    # Use process substitution to run both find commands simultaneously
    while IFS= read -r key && IFS= read -r value <&3; do
        # Assign the key-value pair to the associative array
        sig_to_paths["$key"]="$value"
    done < <(find "${DOCU_PATH}/downloaded/" -type f -name "package-tree.html" -exec sh -c "cat {} | pup 'h1.title' | pandoc -f html -t plain | sed 's/Hierarchy For Package //g'" \;) \
       3< <(find "${DOCU_PATH}/downloaded/" -type f -name "package-tree.html") 

    ## TODO
    ## Associative array can be filled in different ways
    ##      - Using a shell loop
    ## find files -print0 | while read -r file; do commands and pandoc and array
    ## setup; done
    ##      - Using a globstar
    ## for file in "${DOCU_PATH}"/dowloaded/**/package-tree.html; do ... ; done

    # 3) Appending each package-tree 
    #   - After that the package-description 
    #   - After that iterate throguh each object of the package

    for link_from in "${link_from_array[@]}"; do
        echo "# ${link_from} #" >> ${MAIN_TOUPDATE} 
        echo ${link_from} | figlet >> ${MAIN_TOUPDATE} 
        cat "${sig_to_paths["${link_from}"]}" | pup -i 0 --pre 'main' | pandoc -f html -t plain | sed -r 's/(\w*\.\w*\.)\s/\1/g' >> ${MAIN_TOUPDATE}
        directory=$(dirname "${sig_to_paths[${link_from}]}")
        cat ${directory}/package-summary.html | pup 'section#package-description' | pandoc -f html -t plain >> ${MAIN_TOUPDATE}

        # Now we only need to parse each ./package/<object>.html (for the object content)
        #   The only issue is that
        #       There is also a ./package/class-use/<object>.html
        #           <object>.html are same names for both
        #               Information on ./package/class-use subdir is useless
        #           Appart for the ./package/<object>.html  unique signature
        #               Need this to create the link_to

        # We will create an array with ./package/<object>.html
        #       for each iteration on each member
        #            parse ./package/class-use/<object>.html
        #            then ./package/<object>.html (memberValue)
        #       We will need to insert the class-use subdir to the path
     

        mapfile -t object_array < <(find ${directory} -maxdepth 1 -type f \( ! -name "package-*" \))

        for object in "${object_array[@]}"; do
            # Parsing the link to
            # Inserting a parent subdir in a path
            path=${object}
            new_path=$(dirname "$path")/class-use/$(basename "$path")
            
            link_to="# $(cat ${new_path} | pup -i 0 --pre 'h1.title' | pandoc -f html -t plain | sed -E 's/Uses of (Class|Interface|Enum Class|Annotation Interface|Record Class) //g') #"
            echo ${link_to} >> ${MAIN_TOUPDATE}

            ## Parsing the object content
            cat ${object} | pup -i 0 --pre 'main' | pandoc -f html -t plain  >> ${MAIN_TOUPDATE}
        done
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
