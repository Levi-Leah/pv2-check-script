#!/bin/bash

# find current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# find the changed files between master and current branch
changed_files=$(git diff --diff-filter=ACM --name-only master..."$current_branch" -- '*.adoc')

#######################################################################################
abstract='[role="_abstract"]'
add_res='[role="_additional-resources"]'
exp=':experimental:'

# enable tput colors; from J's script
bold=$(tput bold)
fail="$bold$(tput setaf 1)FAIL: "
pass="$bold$(tput setaf 2)PASS: "
warn="$bold$(tput setaf 3)WARNING: "
reset=$(tput sgr0)

path_to_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $path_to_script/src/main.sh
