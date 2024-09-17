#!/bin/bash


## USER TRIGGERED ACTIONS
## ------------------------------------
perfom_install(){
    [ ! -d "${DOCU_PATH}" ] && mkdir -p "${DOCU_PATH}"
    echo "Installing vim-dan ${DOCU_NAME} into ${DOCU_PATH}/ ..."

    # If the file is compressed extract
    if [ -e "$CURRENT_DIR"/ready-docus/main."${DOCU_NAME}dan.bz2" ]; then
        echo "There is compression file"
        bunzip2 -kc "$CURRENT_DIR"/ready-docus/main."${DOCU_NAME}dan.bz2" > ${DOCU_PATH}/main-toupdate.${DOCU_NAME}dan
    else 
        cp $CURRENT_DIR/ready-docus/main.${DOCU_NAME}dan ${DOCU_PATH}/main-toupdate.${DOCU_NAME}dan
        echo " there is no"
    fi
    perform_patch
    updating_tags
    updating_vim
    install_autoload
}
perfom_update(){
    echo "Updating vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
    echo "Note!! . In order for this to have any effect you previously should have updated the repository"
    cp $CURRENT_DIR/ready-docus/main.${DOCU_NAME}dan ${DOCU_PATH}/main.${DOCU_NAME}dan-toupdate
    perform_patch
    updating_tags
    updating_vim
    install_autoload
}

perfom_index(){
    echo "Indexing vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
    ${CURRENT_DIR}/frameworks/${DOCU_NAME}.sh ${DOCU_PATH} "-i"
}

perfom_parse(){
    echo "Parsing vim-dan ${DOCU_NAME} on ${DOCU_PATH}/ ..."
    ${CURRENT_DIR}/frameworks/${DOCU_NAME}.sh ${DOCU_PATH} "-p"
    perform_patch
    updating_tags
    updating_vim
    install_autoload
}
perfom_remove(){
    echo "Removing vim-dan ${DOCU_NAME} off ${DOCU_PATH}/ ..."
    rm -r ${DOCU_PATH}
    rm ${VIM_RTP_DIR}/ftdetect/${DOCU_NAME}dan.vim 
    rm ${VIM_RTP_DIR}/after/ftplugin/${DOCU_NAME}dan.vim 
    rm ${VIM_RTP_DIR}/syntax/${DOCU_NAME}dan.vim 
    rm ${CURRENT_DIR}/autoload/dan.vim 
}
delete_index() {
    echo "Deleting previous Index ..."
    rm -r ${DOCU_PATH}/downloaded
}
install_autoload() {
    if [ -e ${VIM_RTP_DIR}/autoload/dan.vim ]; then
        echo "Installing autoload ..."
        cp ${CURRENT_DIR}/autoload/dan.vim ${VIM_RTP_DIR}/autoload/
    fi
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
        diff <(sed 's/ (X)$//g' ${MAIN_FILE}) ${MAIN_TOUPDATE} | patch ${MAIN_FILE}
        rm ${MAIN_TOUPDATE}
    else
        mv ${MAIN_TOUPDATE} ${MAIN_FILE}
    fi
}

updating_tags() {
    echo "Updating the tag file..."
    ctags --options=NONE --options=${CURRENT_DIR}/ctags-rules/${DOCU_NAME}dan.ctags --tag-relative=always -f ${DOCU_PATH}/tags ${MAIN_FILE} 
    [ ! -d "${HOME}/c.tags.d" ] && mkdir -p "${HOME}/c.tags.d"
    cp ${CURRENT_DIR}/ctags-rules/${DOCU_NAME}dan.ctags ${HOME}/.ctags.d/
}
updating_vim() {
    echo "Updating vim files..."
    [ ! -d "${VIM_RTP_DIR}/ftdetect" ] && mkdir -p "${VIM_RTP_DIR}/ftdetect"
    cp ${CURRENT_DIR}/ft-detection/${DOCU_NAME}dan.vim  ${VIM_RTP_DIR}/ftdetect/
    [ ! -d "${VIM_RTP_DIR}/after/ftplugin" ] && mkdir -p "${VIM_RTP_DIR}/after/ftplugin"
        # If there is own linking-rules then copy them, otherwise use default
        if [ -e ${CURRENT_DIR}/linking-rules/${DOCU_NAME}dan.vim ]; then
            cp ${CURRENT_DIR}/linking-rules/${DOCU_NAME}dan.vim ${VIM_RTP_DIR}/after/ftplugin/${DOCU_NAME}dan.vim
        else
            cp ${CURRENT_DIR}/linking-rules/defaultdan.vim  ${VIM_RTP_DIR}/after/ftplugin/${DOCU_NAME}dan.vim
        fi
    [ ! -d "${VIM_RTP_DIR}/syntax" ] && mkdir -p "${VIM_RTP_DIR}/syntax"
    cp ${CURRENT_DIR}/syntax-rules/${DOCU_NAME}dan.vim  ${VIM_RTP_DIR}/syntax/
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



estimate_docu_weight() {
## Data for indexing, estimating bytes per file
#--------------------
# There are two methods to estimate the aproximated bytes of the documentation.
#   - calculate an html to plaintext ratio , multiply it by number of files
#   - calculate a html_headroom for one file (so the HTML boiler plate
#       that is gonna appear always in each files.
#       The rest should be pure plain text.
#       Get this headroom for the number of files (total_headroom)
#       and substract it to the total size in html
#   Both methods are wrong, it is best the firstone

## Number below may not be representative due to disparity of text on files


mapfile -t files_array < <(find "${DOCU_PATH}/downloaded" -type f -name "*.html" | sort -V)

# Get plaintext size
plaintext_size=$(cat "${files_array[0]}" | pup -i 0 --pre 'article div.devsite-article-body' | pandoc -f html -t plain --wrap=none | wc -c)

# Get HTML file size
html_size=$(stat -c%s "${files_array[0]}")

html_headroom=$((${html_size} - ${plaintext_size}))

echo "HTML headroom: ${html_headroom}"

# get the total number of html files
num_files=$(find "${DOCU_PATH}/downloaded" -maxdepth 1 -type f -name "*.html" | wc -l)

echo "number of html files: ${num_files}"

total_headroom=$((${html_headroom} * ${num_files}))
echo "Total Headroom: ${total_headroom}"

html_size=$(du -sb "${DOCU_PATH}/downloaded" | awk '{print $1}')
echo "html size: ${html_size}"

bytes_total_docu=$((${html_size} - ${total_headroom}))

#$(echo "scale=2; $total_html_size * $plaintext_html_ratio" | bc)


### Calculate the plaintext-to-HTML size ratio (use bc for float division)
##plaintext_html_ratio=$(echo "scale=4; $plaintext_size / $html_size" | bc)
##
##echo ${plaintext_html_ratio}
##echo "Plaintext to HTML ratio: ${plaintext_html_ratio}"

### get the total number of html files
##num_files=$(find "${docu_path}/downloaded" -maxdepth 1 -type f -name "*.html" | wc -l)
##
##echo "number of html files: ${num_files}"
##
### Estimate total plaintext size across all HTML files
##total_html_size=$(find "${DOCU_PATH}/downloaded" -maxdepth 1 -type f -name "*.html" -exec stat -c%s {} + | awk '{s+=$1} END {print s}')

# Estimate total plaintext size across all files
#bytes_total_docu=$(echo "scale=2; $total_html_size * $plaintext_html_ratio" | bc)
# Convert total plaintext bytes to megabytes
bytes_total_docu_mb=$(echo "scale=2; $bytes_total_docu / 1048576" | bc)

echo "Total documentation bytes (estimated plaintext): ${bytes_total_docu} bytes"
echo "Total documentation size (estimated plaintext) in MB: ${bytes_total_docu_mb} MB"
}



## Splitting documentation in different parts of even size
##
## This algorithm will give me the filename for the splits of even size
## and the size of each split , for a certain number of splits given

## We will be assuming that the documentation is sorted and is
## gonna be parsed sorted alphabetically

get_split_files(){

no_splits=$1
path=$2

html_size=$(du -sb "${path}/" | awk '{print $1}')

mapfile -t files_array < <(find "${path}/" -type f -name "*.html" | sort -V )
acumulated_size=0
chunk_size=$((${html_size} / ${no_splits}))
split_count=0

for file in "${files_array[@]}"; do
    current_filesize=$(stat -c%s "${file}")
    acumulated_size=$((${acumulated_size} + ${current_filesize}))

    if [[ ${acumulated_size} -gt ${chunk_size} ]]; then
        split_count=$((${split_count} + 1))
        echo "Split no: ${split_count} split at file: ${file}"
        acumulated_size=0
        if [[ $((${split_count} + 1)) -eq ${no_splits} ]]; then
            break
        fi
    fi
done

}

#get_split_files 3 "${DOCU_PATH}/downloaded" ""




# Similar to previousone , but we will truncate the find to 
# file_start
# file_finnish
get_split_files_partial(){

no_splits=$1
path=$2
file_start=$3
file_finnish=$3

html_size=$(du -sb "${path}/" | awk '{print $1}')

mapfile -t files_array < <(
    find "${path}/" -type f -name "*.html" | sort -V | \
    sed -n "/$file_start/,/$file_finnish/p"
)
acumulated_size=0
chunk_size=$((${html_size} / ${no_splits}))
split_count=0

for file in "${files_array[@]}"; do
    current_filesize=$(stat -c%s "${file}")
    acumulated_size=$((${acumulated_size} + ${current_filesize}))

    if [[ ${acumulated_size} -gt ${chunk_size} ]]; then
        split_count=$((${split_count} + 1))
        echo "Split no: ${split_count} split at file: ${file}"
        acumulated_size=0
        if [[ $((${split_count} + 1)) -eq ${no_splits} ]]; then
            break
        fi
    fi
done

}


#get_split_files 3 "${DOCU_PATH}/downloaded" "${DOCU_PATH}/downloaded/cloud.google.com-)java-)docs.html" "${DOCU_PATH}/downloaded/cloud.google.com-)java-)getting-started-)session-handling-with-firestore.html"

