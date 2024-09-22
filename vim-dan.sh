#!/bin/bash

## USER DEFINED OPTIONS
## ------------------------------------
## Modify accordingly

## VIMDAN_DIR="${HOME}/baul-documents/vim-dan"
## VIM_RTP_DIR="${HOME}/.vim"

## EOF EOF EOF USER DEFINED OPTIONS
## ------------------------------------



## Sourcing files
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"

# Source the user config if it exists
if [[ -f "${CURRENT_DIR}/.vimdan_config" ]]; then
    source "${CURRENT_DIR}/.vimdan_config"
fi


## PARSING FRAMEWORK ARGUMENT
## ------------------------------------
# 1st Check for existing frameworks on the directory
declare -a frameworks_array

mapfile -t frameworks_array < <(find $CURRENT_DIR/frameworks/ -type f -name "*.sh" -exec basename {} .sh \; | sort )

# Function to check if the framework exists
framework_exists() {
    local framework="$1"
    for f in "${frameworks_array[@]}"; do
        [[ "$f" == "$framework" ]] && return 0
    done
    return 1
}

# Parse command-line options
if [[ $# -lt 1 ]]; then
    echo "Select a framework. Available frameworks are:"
    for f in "${frameworks_array[@]}"; do
        echo "${f}"
    done
    exit 1
fi

# Check if the first argument is a valid framework
framework="$1"
shift
if ! framework_exists "$framework"; then
    echo "Invalid framework. Available frameworks are:"
    for f in "${frameworks_array[@]}"; do
        echo "${f}"
    done
    exit 1
fi
## EOF EOF EOF PARSING FRAMEWORK ARGUMENT
## ------------------------------------


## PROCESSING ARGUMENTS
## ------------------------------------
DOCU_NAME=$(basename ${framework} '.sh')
DOCU_PATH="${VIMDAN_DIR}/${DOCU_NAME}"
MAIN_FILE="${DOCU_PATH}/main.${DOCU_NAME}dan"
MAIN_TOUPDATE="${DOCU_PATH}/main-toupdate.${DOCU_NAME}dan"
## EOF EOF EOF PROCESSING ARGUMENTS
## ------------------------------------



## PARSING ARGUMENTS
## ------------------------------------
while getopts ":iupxradth" opt; do
    case ${opt} in
        i)
            perform_install
            ;;
        u)
            perform_update
            ;;
        p)
            perform_parse
            ;;
        x)
            perform_index
            ;;
        r)
            perform_remove
            ;;
        a)
            perform_arrange
            ;;
        t)
            updating_tags
            ;;
        d)
            delete_index
            ;;
        h | *)
            echo "Usage: $0 [FRAMEWORK] [-i] [-u] [-p] [-x] [-r] [-t] [-d] [-h] [-a]"
            echo "Options:"
            echo "  -i  Install Docu"
            echo "  -u  Update Docu"
            echo "  -p  Parse Docu"
            echo "  -x  Index Docu"
            echo "  -r  Remove Docu"
            echo "  -t  Updating Tags"
            echo "  -d  Delete Index"
            echo "  -a  Arraging Docu files"
            echo "  -h  Help"
            exit 0
            ;;
    esac
done
## EOF EOF EOF PARSING ARGUMENTS
## ------------------------------------
