#!/bin/bash

# COLORS
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
PURPLE=$(tput setaf 5)
NORMAL=$(tput sgr0)

# Version, KR stands for KeywordReplacer
KF_VERSION='v1.1.3'

# Docs
DOC_URL='https://github.com/mammadyahyayev/keyword-replacer'

# constant variables
SUPPORTED_FILE_FORMATS=("docx" "pdf")
AUTHOR="Mammad Yahyayev"
AUTHOR_DESC="I am a passionate developer and I love open source projects."
AUTHOR_GITHUB_URL="https://github.com/mammadyahyayev"
AUTHOR_LINKEDIN_URL="https://www.linkedin.com/in/mammad-yahyayev/"

KEY_VALUE_SEPARATOR="="

files=()
keywords=()
txt_files=()
temp_arr=()
declare -A file_map
declare -A key_value_combinations

# file variables
filename=""
file_extension=""
file_dir_path=""
prototype_file_path=""
destination_file_path=""

# log functions
function error() {
    echo $RED"Error: $1"$NORMAL
}

function success() {
    echo $GREEN"$1"$NORMAL
}

function info() {
    echo $CYAN"$1"$NORMAL
}

function info_override() {
    echo -ne "$CYAN[INFO] $1\033[0K\r"$NORMAL
}

function warning() {
    echo $YELLOW"$1"$NORMAL
}

function debug() {
    echo $PURPLE"==> $1"$NORMAL
}

# str functions
function is_str_empty() {
    if [[ -z "${1// /}" ]]; then
        true
    else
        false
    fi
}

# array functions
function is_arr_empty() {
    local arr=("$@")
    local arr_len="${#arr[@]}"

    if [[ $arr_len -eq 0 ]]; then
        true
    else
        false
    fi
}

# directory functions
function is_dir_exist() {
    if [[ -d "$1" ]]; then
        true
    else
        false
    fi
}

# file related functions
function get_filename() {
    local file=$1
    filename=${file##*/}
}

function get_file_extension() {
    local file=$1
    get_filename "$file"
    file_extension="${filename##*.}"
}

function get_file_path() {
    local file=$1
    file_dir_path="${file%/*}"
}

# print functions
function print_newline() {
    count=$1
    i=0
    while [[ i -lt $count ]]; do
        echo $'\n'
        i=$(($i + 1))
    done
}

function print_arr() {
    for item in "$@"; do
        debug "$item"
    done
}

function get_absolute_path() {
    local file=$1
    prototype_file_path=$(readlink -f "$fvalue")
}

function print_dictionary() {
    eval "declare -A dict"=${1#*=}

    for key in ${!dict[@]}; do
        echo "[$key]=${dict[$key]}"
    done
}

function replace_env_variables() {
    cp "$prototype_file_path" "$destination_file_path"

    for key in ${!key_value_combinations[@]}; do
        sed -i "s/<$key>/${key_value_combinations[$key]}/" $destination_file_path
    done
}

while :; do
    case $1 in
    -v | --version)
        echo "KeywordReplacer $KF_VERSION"
        exit 0
        ;;
    -h | --help)
        echo "For documentation refer to: $DOC_URL"
        exit 0
        ;;
    --author)
        echo $GREEN"Developer:$NORMAL   $CYAN==>$NORMAL $AUTHOR"
        echo $GREEN"Bio:$NORMAL         $CYAN==>$NORMAL $AUTHOR_DESC"
        echo $GREEN"Github:$NORMAL      $CYAN==>$NORMAL $AUTHOR_GITHUB_URL"
        echo $GREEN"Linkedin:$NORMAL    $CYAN==>$NORMAL $AUTHOR_LINKEDIN_URL"
        exit 0
        ;;
    -f | --file)
        prototype_file="$2"
        if is_str_empty $prototype_file; then
            error "Please specify file path!"
            exit 1
        fi

        destination_file="$3"
        if is_str_empty $destination_file; then
            error "Please specify destination file path!"
            exit 1
        fi

        prototype_file_path=$(readlink -f "$prototype_file")
        destination_file_path=$(readlink -f "$destination_file")

        all_arguments=("$@")
        for ((index = 0; index < ${#all_arguments[@]}; index++)); do
            case "${all_arguments[index]}" in
            -c | --combination)
                combination="${all_arguments[index + 1]}"
                IFS=$KEY_VALUE_SEPARATOR read -r -a array <<<"$combination"
                key="${array[0]}"
                value="${array[1]}"
                key_value_combinations["$key"]="$value"
                ;;
            esac
        done

        replace_env_variables "$(declare -p key_value_combinations)"

        exit 0
        ;;
    ?)
        error "Unknown flag, plese type $YELLOW sh keyword-finder.sh -h$NORMAL for more info" >&2
        exit 1
        ;;
    esac

    shift
done

# Print Dictionary Command: print_dictionary "$(declare -p key_value_combinations)"
