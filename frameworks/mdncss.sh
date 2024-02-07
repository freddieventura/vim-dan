#!/bin/bash

DOCU_PATH="$1"
shift

indexing_rules(){
    echo "Into Indexing Rules ${0}"

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
      --exclude-directories=en-US/docs/Web/Accessibility,en-US/docs/Web/Accessibility/*,en-US/docs/Web/API,en-US/docs/Web/API/*,en-US/docs/Web/HTML,en-US/docs/Web/HTML/*,en-US/docs/Web/Media,en-US/docs/Web/Media/*,en-US/docs/Web/XML,en-US/docs/Web/XML/*,/en-US/docs/Web/Manifest,/en-US/docs/Web/Manifest/*,/en-US/docs/Web/MathML,/en-US/docs/Web/MathML/*,/en-US/docs/Web/EXSLT,/en-US/docs/Web/EXSLT/*,/en-US/docs/Web/SVG,/en-US/docs/Web/SVG/*,/en-US/docs/Web/XSLT,/en-US/docs/Web/XSLT/*,/en-US/docs/Web/Events,/en-US/docs/Web/Events/*,/en-US/docs/Web/Guide,/en-US/docs/Web/Guide/*,/en-US/docs/Web/Progressive_web_apps,/en-US/docs/Web/Progressive_web_apps/*,/en-US/docs/Web/Performance,/en-US/docs/Web/Performance/*,/en-US/docs/Web/XPath,/en-US/docs/Web/XPath/*,/en-US/docs/Web/Security,/en-US/docs/Web/Security/*,/en-US/docs/Web/JavaScript,/en-US/docs/Web/JavaScript/*,/en-US/docs/Web/HTTP,/en-US/docs/Web/HTTP/* \
      --reject-regex '\\\"' \
      --page-requisites \
      https://developer.mozilla.org/en-US/docs/Web/CSS

}

parsing_rules(){
    echo "Into Parsing Rules ${0}"
}


## PARSING ARGUMENTS
## ------------------------------------
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
