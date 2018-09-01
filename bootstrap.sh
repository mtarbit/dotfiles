#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$script_dir/source"
target_dir=$HOME

script="$(basename "${BASH_SOURCE[0]}")"
manifest='Manifest'
args=("$@")
dryrun=false

color_red=1
color_grn=2
color_ylw=3

function color {
    code=$1
    text=$2
    echo "\033[3${code}m${text}\033[0m"
}

function echo_success {
    echo -e $(color $color_grn "$1")
}

function echo_message {
    echo -e $(color $color_ylw "$1")
}

function echo_failure {
    echo -e $(color $color_red "$1")
}

function create_symlink {
    source=$1
    target=$2

    if [ -h $target ]; then
        echo_message "Existing symlink: $target"
    elif [ ! -e $source ]; then
        echo_failure "Error - Source does not exist: $source"
        echo_failure "Correct path or remove from $manifest to continue."
        exit
    elif [ -e $target ]; then
        echo_failure "Error - Regular file at target location: $target"
        echo_failure "Remove the obstruction and run again to continue."
        exit
    else
        echo_success "Creating symlink: $target "

        if ! $dryrun; then
            ln -s $source $target
        fi

    fi
}

function remove_symlink {
    target=$1

    if [ -h $target ]; then
        echo_success "Removing symlink: $target"

        if ! $dryrun; then
            rm $target
        fi

    elif [ -e $target ]; then
        echo_failure "Warning - Regular file at target location: $target"
    else
        echo_message "Nothing to do for: $target"
    fi
}

function install {
    echo "Installing dotfile symlinks..."
    while read path; do
        create_symlink "$source_dir/$path" "$target_dir/$path"
    done < $manifest
    echo "Done"
}

function uninstall {
    echo "Uninstalling dotfile symlinks..."
    while read path; do
        remove_symlink "$target_dir/$path"
    done < $manifest
    echo "Done"
}

function update {
    # TODO:
    # - Git fetch and merge or rebase changes.
    # - Add or remove symlinks to match manifest.
    # - Git update submodules.
    echo "The update command is not yet implemented."
}

function usage {
    echo "Usage: $script [<command>] [-d|--dry-run]"
    echo "Where <command> is 'install', 'uninstall' or 'update'."
    exit 0
}

for (( i = ${#args[@]} - 1; i >= 0; i-- )); do
    case ${args[i]} in
        -d | --dry-run)
            echo "(DRY RUN: No changes will be made)"
            dryrun=true
            unset args[i];;
        -h | --help)
            usage
            unset args[i];;
        -*)
            echo "Unrecognised option: ${args[i]}"
            usage
            unset args[i];;
    esac
done

if [ ${#args[@]} -gt 1 ]; then
    usage
fi

case ${args[0]} in
    ''          ) install;;
    'install'   ) install;;
    'uninstall' ) uninstall;;
    'update'    ) update;;
    *           ) usage;;
esac
