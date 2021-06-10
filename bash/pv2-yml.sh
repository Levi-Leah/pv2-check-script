 #!/bin/bash

#######################################################################################
# this section is for working on the merge request
# find current branch
#current_branch=$(git rev-parse --abbrev-ref HEAD)

# find the changed files between master and current branch
#changed_files=$(git diff --diff-filter=ACM --name-only master..."$current_branch" -- '*.adoc')
#######################################################################################
abstract='[role="_abstract"]'
add_res='[role="_additional-resources"]'
exp=':experimental:'

# enable tput colors; from J's script
bold=$(tput bold)
fail="$bold$(tput setaf 1)"
pass="$bold$(tput setaf 2)"
reset=$(tput sgr0)

# record all files in the pantheon2.yml file
# rhel-8/common-content/attributes.adoc is excluded
all_yml_files=$(grep -v 'rhel-8/common-content/attributes.adoc' pantheon2.yml | grep -o "rhel-.\/.*.adoc")

# record all files that exist in path
#old that works
#changed_files=$(for i in $(echo "$all_yml_files"); do find "$i"; done )
changed_files=$(echo "$all_yml_files" | xargs -I %% bash -c '[[ -e %% ]] && echo "%%" || echo "${fail}file does not exist in path:${reset} %%" >&2')

#######################################################################################
# Checking abstract tags
# record changed files that don't have abstract tag
no_abstract_tag_files=$(echo "$changed_files" | while read line; do grep -FHL --exclude='master.adoc' "$abstract" "$line"; done )

# print a message regarding the abstract tag status
if [ -z "$no_abstract_tag_files" ]; then
    echo "${pass}abstract tags are set${reset}"
else
    echo -e "${fail}no abstract tag in the following files:${reset}\n$no_abstract_tag_files"
fi

#remove
#abstract_tag_files=$(echo "$changed_files" | while read line; do grep -FHl "$abstract" "$line"; done )

#######################################################################################
# Checking additional resources tags
# record changed files that have additional resources section
add_res_files=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*$|d" | grep -q "Additional resources" && echo "%%"')

# old that works
#add_res_files=$(echo "$changed_files" | while read line; do grep -FHl "Additional resources" "$line"; done )

# print a message if no files have additional resources section
if [[ -z "$add_res_files" ]]; then
   echo "${pass}no files contain additional resources section${reset}"
fi

# print a message if files have additional resources section
if ! [[ -z "$add_res_files" ]]; then
    # record changed files that have no additional resources tag
    no_add_res_tag_files=$(echo "$add_res_files" | while read line; do grep -FHL "$add_res" "$line"; done );
    if [ -z "$no_add_res_tag_files" ]; then
        # print a message regarding additional resources tag status
        echo "${pass}additional resorces tags are set${reset}"
    else
        echo -e "${fail}no additional resources tag in the following files:${reset}\n$no_add_res_tag_files"
    fi
fi

#######################################################################################
# Checking empty lines after the abstract tag
# record changed files that have an empty line after the abstract tag
empty_line_after_abstract=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\$!N;/^\[role\=\"\_abstract\"\]\n$/p;D" %% | grep -q "\[role=\"_abstract\"\]" && echo "%%"')

# print a message regarding the empty line after the abstract status
if [[ -z "$empty_line_after_abstract" ]]; then
    echo "${pass}no files contain an empty line after the abstract tag${reset}"
else
    echo -e "${fail}the following files have an empty line after the abstract tag:${reset}\n$empty_line_after_abstract"
fi

#######################################################################################
# Checking empty lines after the additional resources tag
# record changed files that have an empty line after the additional resources tag
empty_line_after_add_res=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\$!N;/^\[role=\"_additional-resources\"\]\n$/p;D" %% | grep -q "\[role=\"_additional-resources\"\]" && echo "%%"')

# print a message regarding the empty line after the abstract status
if [[ -z "$empty_line_after_add_res" ]]; then
    echo "${pass}no files contain an empty line after the additional resources tag${reset}"
else
    echo -e "${fail}the following files have an empty line after the additional resources tag:${reset}\n$empty_line_after_add_res"
fi


#######################################################################################
# Checking empty lines between additional resources header and the first bullet point
# record changed files that have an empty line between additional resources header and the first bullet point
empty_line_after_add_res_header=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\$!N;/.*Additional resources\n$/p;D" %% | grep -q ".*Additional resources" && echo "%%"')

# print a message regarding the empty line after the abstract status
if [[ -z "$empty_line_after_add_res_header" ]]; then
    echo "${pass}no files contain an empty line after the additional resources tag${reset}"
else
    echo -e "${fail}the following files have an empty line after the additional resources tag:${reset}\n$empty_line_after_add_res_header"
fi

#######################################################################################
# Checking vanilla xrefs
# record changed files that have vanilla xrefs (scipping the comments)
vanilla_xref_files=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*$|d" | sed -re "\|<<.* .*>>|d" | grep -q "<<.*>>" && echo "%%"')

#old that works
#vanilla_xref_files=$(echo "$changed_files" | while read line; do grep -HlE '<<.*>>' "$line"; done )

# print a message regarding vanilla xref status
if [ -z "$vanilla_xref_files" ]; then
    echo "${pass}no vanilla xrefs found${reset}"
else
    echo -e "${fail}vanilla xrefs found in the following files:${reset}\n$vanilla_xref_files"
fi

#######################################################################################
# Checking in-line anchors
# record changed files that have in-line anchors
in_line_anchor_files=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*$|d" | grep -q "^=.*\[\[.*\]\]" && echo "%%"')

# old that works
#in_line_anchor_files=$(echo "$changed_files" | while read line; do grep -HlE "^=.*\[\[.*\]\]" "$line"; done )

# print a message regarding in-line anchors status
if [ -z "$in_line_anchor_files" ]; then
    echo "${pass}no in-line anchors found${reset}"
else
    echo -e "${fail}in-line anchors found in the following files:${reset}\n$in_line_anchor_files"
fi

#######################################################################################
# Checking human readable regular xrefs
# record changed files that have xrefs without human readable label
no_human_read_tag_xrefs=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*|d" | grep -q "xref:.*\[\]" && echo "%%"')

# record changed files that have links without human readable label
no_human_read_tag_links=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*|d" | grep -q "http.*\[\]" && echo "%%"')

if [ -z "$no_human_read_tag_xrefs" ]; then
    echo "human readable labels are set in xrefs"
else
    echo -e "${fail}human readable labels for xrefs are missing in the following files:${reset}\n$no_human_read_tag_xrefs"
fi

if [ -z "$no_human_read_tag_links" ]; then
    echo "human readable labels are set in links"
else
    echo -e "${fail}human readable labels for links are missing in the following files:${reset}\n$no_human_read_tag_links"
fi

#######################################################################################
# Checking nesting in assemblies
# record changed files that are assemblies
assembly_files=$(echo "$changed_files" | grep "assembly_")

# print a message if no assembly files were changed
if [[ -z "$assembly_files" ]]; then
   echo "${pass}no assembly files were changed${reset}"
fi

# print a message if assembly files were changed
if ! [[ -z "$assembly_files" ]]; then
    # record assemblies that contain other assemblies
    nesting_in_assemblies=$(echo "$assembly_files" | while read line; do grep -HlE "^include::assembly_*" "$line"; done )

    # print a message regarding nesting in assemblies
    if [ -z "$nesting_in_assemblies" ]; then
        echo "${pass}assemblies do not contain nested assemblies${reset}"
    else
        echo -e "${fail}nested assemblies found in the following assemblies:${reset}\n$nesting_in_assemblies"
    fi
    # record assemblies that contain unsopported includes
    unsopported_includes_files=$(echo "$assembly_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*$|d" | grep -q ":leveloffset:" && echo "%%"')
    #while read line; do grep -HlE ":leveloffset:" "$line"; done )
    if [ -z "$unsopported_includes_files" ]; then

        # print a message regarding includes in assemblies
        echo "${pass}supported includes are used in assemblies${reset}"
    else
        echo -e "${fail}unsupported includes found in the following files:${reset}\n$unsopported_includes_files"
    fi
fi

#######################################################################################
# Checking nesting in modules
# record changed files that are modules
module_files=$(echo "$changed_files" | grep "\/modules\/")

# if no module files are changes
if [[ -z "$module_files" ]]; then
    echo "${pass}no module files were changed${reset}"
fi

# if module files are changed
if ! [[ -z "$module_files" ]]; then
    # record changed modules that have nested modules
    # comments and anything with common-content dir in path is excluded
    nesting_in_modules=$(echo "$module_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*$|d" | sed -re "\|^include::common-content|d" | grep -q "^include::*" && echo "%%"')
    # print a message regarding nesting in modules
    if [ -z "$nesting_in_modules" ]; then
        echo "${pass}modules do not contain nested modules${reset}"
    else
        echo -e "${fail}nested modules found in the following files:${reset}\n$nesting_in_modules"
    fi
fi

#######################################################################################
# Checking UI Macros
# record changed files that have UI Macros
ui_macros_files=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*$|d" | grep -q -e "btn:\[.*\]" -e "menu:.*\[.*\]" -e "kbd:\[.*\]" && echo "%%"')

# print a message if no files have UI Macros
if [[ -z "$ui_macros_files" ]]; then
   echo "${pass}no files contain UI Macros${reset}"
fi

# print a message if files have UI macros
if ! [[ -z "$ui_macros_files" ]]; then
    # record changed files that have no experimental tag
    no_experimental_tag_files=$(echo "$ui_macros_files" | while read line; do grep -FHL "$exp" "$line"; done );
    if [ -z "$no_experimental_tag_files" ]; then
        # print a message regarding experimental tag status
        echo "${pass}experimental tags is set${reset}"
    else
        echo -e "${fail}experimental tag in not set in the following files:${reset}\n$no_experimental_tag_files"
    fi
fi

#######################################################################################
# Checking HTML markup
# record changed files that have HTML markup
html_markup_files=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*$|d" | sed -re "\|^\.\.\.\.|,\|^\.\.\.\.|d" | sed -re "\|^----|,\|^----|d" | grep -q "<.*>.*<\/.*>" && echo "%%"')

# print a message regarding HTML markup status
if [[ -z "$html_markup_files" ]]; then
   echo "${pass}no files contain HTML markup${reset}"
else
    echo -e "${fail}HTML markup is found in the following files:${reset}\n$html_markup_files"
fi

#######################################################################################
# Checking variables in titles
# record changed files that have variables in titles
variables_in_titles=$(echo "$changed_files" | xargs -I %% bash -c 'sed -re "\|^////|,\|^////|d" %% | sed -re "\|^//.*$|d" | sed -re "\|\{context\}|d" | grep -q "^=.*{.*}" && echo "%%"')

# print a message regarding variables in titles status
if [[ -z "$variables_in_titles" ]]; then
   echo "${pass}no files have variables in titles${reset}"
else
    echo -e "${fail}the following files have variable in the titles:${reset}\n$variables_in_titles"
fi
