#!/bin/bash

## DESCRIPTION: convert a document from one format to another one 

## AUTHOR: Hui Zheng

readonly SH_DIR="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"
readonly SCRIPT_NAME=$(basename "$BASH_SOURCE")

## exit the shell(default status code: 1) after printing the message to stderr
bail() {
    echo -ne "$1" >&2
    exit ${2-1}
} 


## help message
declare -r HELP_MSG="Usage: $SCRIPT_NAME [OPTION]...
    -c clean
    -f FORMAT (default: epub)
    -h display this help and exit
    -n dry run
    -o output (default: current_directory_name+DOT+FORMAT)
    -C do nothing but clean
"

## print the usage and exit the shell(default status code: 2)
usage() {
    declare status=2
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        status=$1
        shift
    fi
    bail "${1}$HELP_MSG" $status
}

readonly CUR_DIR=${PWD##*/}
declare cmd="make -f $SH_DIR/Makefile " 
declare dry_run=0
declare format=epub
declare clean=0
while getopts ":cf:hno:C" opt; do
    case $opt in
        c)
            clean=1
            ;;
        f)
            format=$OPTARG
            ;;
        h)
            usage 0;;
        n)
            dry_run=1
            ;;
        o)
            output=$OPTARG
            ;;
        C)
            clean=2
            ;;
        \?)
            usage "Invalid option: -$OPTARG \n";;
    esac
done

shift $(($OPTIND - 1))


if [ -z "${output}" ]; then
    output=$CUR_DIR.$format
fi

if [ "$clean" -eq 1 ]; then
    cmd+="clean $output"
elif [ "$clean" -eq 2 ]; then
    cmd+="clean"
else
    cmd+="$output"
fi

if [ "$dry_run" -eq 1 ]; then
    echo $cmd
else
    echo runnig $cmd
    eval "$cmd"
fi
