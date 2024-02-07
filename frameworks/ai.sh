#!/bin/bash

DOCU_PATH="$1"
shift

indexing_rules(){
    echo "Into Indexing Rules ${0}"
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
