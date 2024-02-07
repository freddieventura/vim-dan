#!/bin/bash


## USER TRIGGERED ACTIONS
## ------------------------------------
perfom_install(){
    if [ ! -d "${DOCU_PATH}" ]; then
        mkdir -p "${DOCU_PATH}"
    fi
    echo "Installing vim-dan ${DOCU_NAME} into ${DOCU_PATH}/ ..."
    cp $CURRENT_DIR/ready-docus/main.${DOCU_NAME}dan ${DOCU_PATH}/main.${DOCU_NAME}dan-toupdate
    perform_patch
}

perfom_update(){
    echo "Updating vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
    echo "Note!! . In order for this to have any effect you previously should have updated the repository"
    cp $CURRENT_DIR/ready-docus/main.${DOCU_NAME}dan ${DOCU_PATH}/main.${DOCU_NAME}dan-toupdate
    perform_patch
}

perfom_index(){
    echo "Indexing vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
#    delete_index
    ${CURRENT_DIR}/frameworks/${DOCU_NAME}.sh ${DOCU_PATH} "-i"
}

perfom_parse(){
    echo "Parsing vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
    ${CURRENT_DIR}/frameworks/${DOCU_NAME}.sh ${DOCU_PATH} "-p"
#    delete_index
}

perfom_remove(){
    echo "Removing vim-dan ${DOCU_NAME} off ${DOCU_PATH}/ ..."
    rm -r ${DOCU_PATH}
}

## EOF EOF EOFF USER TRIGGERED ACTIONS
## ------------------------------------


## AUTOMATIC ACTIONS
## ------------------------------------
perform_patch(){
    echo "Patching the documentation..."
    # Patching the localdocu
    # If performed for the first-time just use the new index
    if [ -e ${MAIN_FILE} ]; then
        cp ${MAIN_FILE} ${MAIN_FILE}-bk
        diff <(sed 's/ (X)$//g' ${MAIN_FILE}) ${MAIN_FILE}-toupdate | patch ${MAIN_FILE}
        rm ${MAIN_FILE}-toupdate
    else
        mv ${MAIN_FILE}-toupdate ${MAIN_FILE}
    fi
}

delete_index() {
    echo "Deleting previous Index ..."
    rm -r ${DOCU_PATH}/downloaded
}
## EOF EOF EOF AUTOMATIC ACTIONS
## ------------------------------------




## FUNCTIONS TO BE USED ON INDEXING/PARSING
## ------------------------------------
function getItemsNLevelDir() {
# This function will print out all the files that are N Levels below a certain
#   Subdirectory
#           - items: (f for files, d for directories , man find)
#           - level: Int, How many levels below you want to check
#           - directory : subdirectory to check, must be found below the current
#                           path. Just a string with the directory name no "/"
#           - recursion : it will check for items on all the subdirectories b
#                           below
#           i.e:  getItemsNLevelDir "f" "1" "Global_Objects" "no"   will 
#                   List all the direct children files of Global_Objects subdir
items=$1
level=$2
directory=$3
recursion=$4
regex="[A-Za-z0-9_/.-]*${directory}"

for (( i=2; i<((${level} + 1)); i++ )); do
    echo ${i};
    regex+="\/[A-Za-z0-9_-]*"
done

if [ ${recursion} == 'yes' ]; then
    regex+="\/[A-Za-z0-9_/.-]*"
else
    regex+="\/[A-Za-z0-9_.-]*"
fi

echo ${regex}
find ./ -type ${items} -regex ${regex}
}

find_same_name_sibling_directory() {
# For a certain extension, it gives you the file path of the ones that have
#   a sibling folder of the same name
#       i.e: find_same_name_sibling_directory '.' 'html'
    local dir="$1"
    local ext="$2"
    # Find all .EXT files in the directory
    ext_files=$(find "$dir" -maxdepth 1 -type f -name "*.${ext}" -printf "%f\n")
    
    # Loop through EXT files
    for ext_file in $ext_files; do
        # Check if there's a corresponding directory with the same name
        if [ -d "${dir}/${ext_file%.*}" ]; then
            echo "${dir}/${ext_file}"
        fi
    done

    # Recursively process subdirectories
    subdirs=$(find "$dir" -mindepth 1 -maxdepth 1 -type d)
    for subdir in $subdirs; do
        find_same_name_sibling_directory "$subdir" "$ext"
    done
}
## EOF EOF EOF FUNCTIONS TO BE USED ON INDEXING/PARSING
## ------------------------------------
