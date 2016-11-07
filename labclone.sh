#!/usr/bin/env bash

TOKEN="XXXXXXXXXXXXX"
PREFIX="ssh_url_to_repo" 

function list {
/usr/bin/curl -s --header "PRIVATE-TOKEN: $TOKEN" https://gitlab.project.com/api/v3/groups?per_page=200 | grep -o "\"id\":[^ ,]\+","\"name\":[^ ,]\+" | awk -F '"' '{print $3 $6}' | cut -d : -f2-
}

function clone {
/usr/bin/curl -s --header "PRIVATE-TOKEN: $TOKEN" https://gitlab.project.com/api/v3/groups/$1/projects?per_page=200 | grep -o "\"$PREFIX\":[^ ,]\+" | awk -F ':' '{printf "ssh://"; for (i=2; i<NF; i++) printf $i "/"; print $NF}' | xargs -L1 git clone
}


if [ ! -z $1 ] ; then
        case "$1" in
                -l) list ;;
		-c) for i in `list | cut -d , -f2` ; do mkdir $i; done  ;;
                -h|--help) 
		echo "labclone [options] or [PROJECT ID]"
		echo "-h, --help	Print this help"
		echo "-l		List project id"
		echo "-c		create projects directories" 
		exit 1 ;;
                *) clone $1 ;;
        esac ;
else
                echo "labclone [options] or [PROJECT ID]"
                echo "-h, --help        Print this help"
		echo "-l		List project id"
		echo "-c		create projects directories" 
                exit 1 ;
fi
