#!/usr/bin/env bash

# synchro your gitlabs projects, in once 
# Jerem

TOKEN="XXXXXXXXX"
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
                echo "labclone [options] or labclone [REPOS_ID] or clone current directory repos"
		echo ""
		echo "-h, --help	Print this help"
		echo "-l		List projects id"
		echo "-c		Create projects directories" 
		echo "-r		Recursivly clone projects" 
                echo "-p                Recursivly pull projects (maxdepth=1)" 
		exit 1 ;;
                -r) for i in `ls` ; do cd $i && clone  `pwd | awk -F / '{print $NF}' | cut -d , -f1` && cd - ; done ;; 
                -p) for i in `ls` ; do cd $i && git pull && cd - ; done ;; 
                *) clone $1 ;; 
        esac ;
else
                clone `pwd | awk -F / '{print $NF}' | cut -d , -f1`
fi
