 #!/bin/bash

# defining the basics
abstract='[role="_abstract"]'
add_res='[role="_additional-resources"]'
exp=':experimental:'

# enable tput colors; from J's script
bold=$(tput bold)
fail="$bold$(tput setaf 1)FAIL: "
pass="$bold$(tput setaf 2)PASS: "
warn="$bold$(tput setaf 3)WARNING: "
ex="$bold$(tput smul)"
reset=$(tput sgr0)
reset_ex=$(tput rmul)

#ask for user input
echo -e "${bold}enter the file name that contains paths to the files you want to check ${ex}(e.g. pantheon2.yml)${reset_ex}.
> if your file is not in the ${ex}rhel-8-docs${reset_ex} directory, provide the absolute path ${ex}(e.g. /home/user/some-file)${reset_ex}${reset}."

#record user input
read input_file

# test if the file provided by the user exists
if test -f "$input_file"; then
    echo "${pass}$input_file file exists. checking the contents of the $input_file file...${reset}"
else
    echo "${fail}$input_file does not exist
    > provide the absolute path ${ex}(e.g. /home/user/some-file)${reset_ex}
    > do not start the path with ~ tilda sign${reset}"
    exit
fi

# determine if the files are in enterprise or in rhel-* directory
old_vs_new=$(cat "$input_file" | grep -o "enterprise\/.*.adoc")

# if files are not in enterprise directory grep all the rhel-*/.*.adoc files
if [ -z "$old_vs_new" ]; then
    # rhel-*/common-content/attributes.adoc is excluded
    all_files=$(grep -v 'rhel-*/common-content/attributes.adoc' $input_file | grep -o "rhel-.\/.*.adoc")
fi

# if files are in enterprise directory grep all the enterprise/.*.adoc files
if ! [ -z "$old_vs_new" ]; then
    # enterprise/meta/attributes.adoc is excluded
    all_files=$(grep -v 'meta/attributes.adoc' $input_file | grep -o "enterprise\/.*.adoc")
fi

# check if any file paths suitable for the check were recorded
if [ -z "$all_files" ]; then
    echo "${fail}$input_file does not contain file paths suitable for the check
    > enter the file name that contains paths to the files you want to check ${ex}(e.g. pantheon2.yml)${reset_ex}${reset}"
    exit
fi

# record all files that exist in path
#legacy command
#changed_files=$(for i in $(echo "$all_files"); do find "$i"; done )
changed_files=$(echo "$all_files" | xargs -I %% bash -c '[[ -e %% ]] && echo "%%" || echo "file does not exist in path: %%" >&2')

path_to_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $path_to_script/src/main.sh
