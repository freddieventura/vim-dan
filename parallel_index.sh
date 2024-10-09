#!/bin/bash
source `which env_parallel.bash`
INVOKING_HOSTNAME=$(hostname)
temp_file="temp_file.csv"
url_list="url-list.csv"


main(){
env_parallel --env INVOKING_HOSTNAME --env down_and_pull --env check_disk_space -S 192.168.43.241 -a "url-list.csv" down_and_pull | tee -a "${temp_file}"
mv "${temp_file}" "${url_list}"
}


# Function to handle interrupts (Ctrl+C)
handle_interrupt() {
    echo -e "\nInterrupt received! Updating CSV before exit..."
    update_file
    exit 0
}


# Set trap to catch SIGINT (Ctrl + C)
trap handle_interrupt SIGINT



update_file(){
    # Count the number of lines in temp_file
    num_lines=$(wc -l < "$temp_file")

    # Cut the first 'num_lines' lines from url_list and store the result in a temp file
    tail -n +"$((num_lines + 1))" "$url_list" > "${url_list}.tmp"

    # Prepend the content of temp_file to the cutted url_list
    cat "$temp_file" "${url_list}.tmp" > "${url_list}.new"

    # Replace the original url_list with the new one
    mv "${url_list}.new" "$url_list"

    # Clean up the temporary file
    rm -f "${url_list}.tmp"
}




check_disk_space() {
    MASTER_USER=${1}
    MASTER_IP=${2}
    MASTER_PORT=${3}
    RETURN_PATH=${4}
    DOCU_NAME=${5}
    if [ $(df | awk -v disk="${MAIN_DISK}" '$1 == disk {print $4}') -gt 512000 ]; then
        :
    else
       rsync -av -e "ssh -p ${MASTER_PORT}" --remove-source-files "${DOWN_PATH}/${DOCU_NAME}/" ${MASTER_USER}@${MASTER_IP}:"${RETURN_PATH}/${DOCU_NAME}/" > /dev/null 2>&1
    fi
}

export -f check_disk_space



down_and_pull(){


IS_MASTER="no"
MASTER_USER="fakuve"
MASTER_IP="10.7.0.2"
MASTER_PORT="8022"
RETURN_PATH="/home/fakuve/downloads"

DOCU_NAME="shopify.dev"

    row=$1

    ## Skip the header
    [ "${row}" == "url,exit_status" ] && echo "url,exit_status" && return
     
    url=$(echo "$row" | sed 's/,-*[0-9]*$//')
    path=$(echo "$url" | sed 's|https://||;s|/[^/]*$||')
    filename=$(basename "$url")

    ## If current hostname is not the same as invoking hostname, then transfer bits
    if [[ ${HOSTNAME} != ${INVOKING_HOSTNAME} ]]; then
        check_disk_space ${MASTER_USER} ${MASTER_IP} ${MASTER_PORT} ${RETURN_PART} ${DOCU_NAME}
    fi

    [ ! -d "${DOWN_PATH}/${path}" ] && mkdir -p "${DOWN_PATH}${path}"
    wget --directory-prefix=${HOME}/${path} ${url} > /dev/null 2>&1
    wget_status=${?}
    row="${url},${wget_status}"
    echo ${row}
}
export -f down_and_pull

main
