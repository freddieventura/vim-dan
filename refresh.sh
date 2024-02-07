#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"
source "$CURRENT_DIR/frameworks/*.sh"

VIM-DAN_DIR=$HOME/vim-dan


perform_indexing() {
    indexing_mdnjs(){
    }
    indexing_mdnwebapi(){
    }
    echo "Indexing the documentation  ..."
    mkdir downloaded
    wget \
    `## Basic Startup Options` \
      --execute robots=off \
    `## Loggin and Input File Options` \
    `## Download Options` \
      --timestamping \
    `## Directory Options` \
      --directory-prefix=./downloaded \
      -nH --cut-dirs=3 \
    `## HTTP Options` \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59" \
      --adjust-extension \
    `## HTTPS Options` \
      --no-check-certificate \
    `## Recursive Retrieval Options` \
      --recursive --level=4 \
    `## Recursive Accept/Reject Options` \
      --no-parent \
      --reject '*.svg,*.js,*json,*.css,*.png,*.xml,*.txt' \
      --exclude-directories=en-US/docs/Web/Accessibility,en-US/docs/Web/Accessibility/*,en-US/docs/Web/API,en-US/docs/Web/API/*,en-US/docs/Web/CSS,en-US/docs/Web/CSS/*,en-US/docs/Web/HTML,en-US/docs/Web/HTML/*,en-US/docs/Web/Media,en-US/docs/Web/Media/*,en-US/docs/Web/XML,en-US/docs/Web/XML/*,/en-US/docs/Web/Manifest,/en-US/docs/Web/Manifest/*,/en-US/docs/Web/MathML,/en-US/docs/Web/MathML/*,/en-US/docs/Web/EXSLT,/en-US/docs/Web/EXSLT/*,/en-US/docs/Web/SVG,/en-US/docs/Web/SVG/*,/en-US/docs/Web/XSLT,/en-US/docs/Web/XSLT/*,/en-US/docs/Web/Events,/en-US/docs/Web/Events/*,/en-US/docs/Web/Guide,/en-US/docs/Web/Guide/*,/en-US/docs/Web/Progressive_web_apps,/en-US/docs/Web/Progressive_web_apps/*,/en-US/docs/Web/Performance,/en-US/docs/Web/Performance/*,/en-US/docs/Web/XPath,/en-US/docs/Web/XPath/*,/en-US/docs/Web/Security,/en-US/docs/Web/Security/*,/en-US/docs/Web/HTTP,/en-US/docs/Web/HTTP/* \
      --reject-regex '\\\"' \
      --page-requisites \
      https://developer.mozilla.org/en-US/docs/Web/JavaScript
}

delete_index() {
    echo "Deleting previous Index ..."
    rm -r ./downloaded
}

perform_parsing() {
    parsing_mdnjs() {
    }
    parsing_mdnwebapi() {
    }
    echo "Parsing the documentation  ..."
    # Parsing index file
    cat ./downloaded/JavaScript.html | pup -i 0 --pre '.sidebar-inner-nav' | pandoc -f html -t plain > main-toupdate.mdnjsdan

    # Parsing topics
    mapfile -t files_array < <(find ./downloaded/JavaScript -type f -name "*" | sort )

    # Navigation will only be parsed on .html files with same name directory
    mapfile -t nav_inclusion_array < <(find_same_name_sibling_directory '.' 'html')
#    mapfile -t nav_inclusion_array < <(getItemsNLevelDir "f" "2" "Global_Objects" "yes" | sort )

    for file in "${files_array[@]}"; do
        #Parsing headers
        cat ${file} | pup -i 0 --pre 'header h1' | pandoc -f html -t plain > ./topic-toupdate.txt



        for nav_inclusion_file in "${nav_inclusion_array[@]}";do
            if [ ${file} == ${nav_inclusion_file} ]; then
                cat ${file} | pup -i 0 --pre 'details[open]' | pandoc -f html -t plain >> ./topic-toupdate.txt
                break;
            fi
        done

        #Parsing content
        cat ${file} | pup -i 0 --pre '#content' | pandoc -f html -t plain >> ./topic-toupdate.txt

        sed -i '1s/^/# /; 1s/$/ #/' ./topic-toupdate.txt
        cat ./topic-toupdate.txt >> main-toupdate.mdnjsdan
    done

    # Deleting buffer files
    rm ./topic-toupdate.txt
}



perform_patching() {
    echo "Patching the documentation..."
    # Patching the localdocu
    # If performed for the first-time just use the new index
    if [ -e main.mdnjsdan ]; then
        cp main.mdnjsdan main.mdnjsdan-bk
        diff <(sed 's/ (X)$//g' main.mdnjsdan) main-toupdate.mdnjsdan | patch main.mdnjsdan
        rm main-toupdate.mdnjsdan
    else
        mv main-toupdate.mdnjsdan main.mdnjsdan
    fi
}

# Parse command-line options
while getopts "idpth" opt; do
    case ${opt} in
        i)
            perform_indexing
            ;;
        d)
            delete_index
            ;;
        p)
            perform_parsing
            ;;
        t)
            perform_patching
            ;;
        h | *)
            echo "Usage: $0 [-i] [-d] [-p] [-t]"
            echo "Options:"
            echo "  -i  Perform indexing"
            echo "  -d  Delete index"
            echo "  -p  Perform parsing"
            echo "  -t  Perform patching"
            echo "  -h  Display this help message"
            exit 0
            ;;
    esac
done

# Shift the command-line options so that $1 now refers to the first non-option argument
shift $((OPTIND -1))


# Updating the tags
echo "Updating the tag file..."
ctags --options=NONE --options=./mdnjsdan.ctags main.mdnjsdan
