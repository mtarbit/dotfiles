#!/bin/bash

script_dir="$(dirname "${BASH_SOURCE[0]}")"
script="$(basename "${BASH_SOURCE[0]}")"

source_dir="$script_dir/source"
target_dir=$HOME
manifest='Manifest'

red=1
grn=2
ylw=3

function color {
  code=$1
  text=$2
  echo "\033[3${code}m${text}\033[0m"
} 

function create_symlink {
  source=$1
  target=$2

  if [ -h $target ]; then
    echo -e $(color $ylw "Existing symlink: $target")
  elif [ ! -e $source ]; then
    echo -e $(color $red "Error - Source does not exist: $source")
    echo -e $(color $red "Correct path or remove from $manifest to continue.")
    exit
  elif [ -e $target ]; then
    echo -e $(color $red "Error - Regular file at target location: $target")
    echo -e $(color $red "Remove the obstruction and run again to continue.")
    exit
  else
    echo -e $(color $grn "Creating symlink: $target ")

    if ! $dryrun; then
      ln -s $source $target
    fi

  fi
}

function remove_symlink {
  target=$1

  if [ -h $target ]; then
    echo -e $(color $grn "Removing symlink: $target")

    if ! $dryrun; then
      rm $target
    fi

  elif [ -e $target ]; then
    echo -e $(color $red "Warning - Found regular file in target location: $target")
  else
    echo -e $(color $ylw "Nothing to do for: $target")
  fi
}

function install {
  echo "Installing dotfile symlinks..."
  while read path; do
    create_symlink "$source_dir/$path" "$target_dir/$path"
  done < $manifest

  echo "Initializing git submodules..."
  if ! $dryrun; then
    git submodule update --init --recursive
  fi

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
  # TODO:
  # - Git fetch and merge or rebase changes.
  # - Add or remove symlinks to match manifest.
  # - Git update submodules.
  true
}

function usage {
  echo "Usage: $script [<command>] [-d|--dry-run]"
  echo "Where <command> is 'install', 'uninstall' or 'udate'."
  exit 0
}

args=("$@")

for (( i = $# - 1; i >= 0; i-- )); do
  case ${args[i]} in
    -d | --dry-run)
      echo "(DRY RUN: No changes will be made)"
      dryrun=true
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
