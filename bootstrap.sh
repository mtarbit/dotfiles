#!/bin/bash

source_dir="$(dirname ${BASH_SOURCE[0]})/source"
target_dir=$HOME
manifest=Manifest

grn=1
red=2
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
    echo -e $(color $red "Correct path or remove from $manifest to continue")
    exit
  elif [ -e $target ]; then
    echo -e $(color $red "Error - Regular file at target location: $target")
    echo -e $(color $red "Remove the obstruction and run again to continue")
    exit
  else
    echo -e $(color $grn "Creating symlink: $target ")
    # ln -s $source $target
  fi
}

function remove_symlink {
  target=$1

  if [ -h $target ]; then
    echo -e $(color $grn "Removing symlink $target")
    # rm $target
  elif [ -e $target ]; then
    echo -e $(color $ylw "Warning - Found regular file in target location: $target")
  else
    echo -e $(color $grn "Nothing to do for $target")
  fi
}

function install {
  echo "Installing dotpath symlinks..."
  while read path; do
    create_symlink $source_dir/$path $target_dir/$path
  done < $manifest
  echo "Done"
}

function uninstall {
  echo "Uninstalling dotpath symlinks..."
  while read path; do
    remove_symlink $target_dir/$path
  done < $manifest
  echo "Done"
}

case $1 in
  'uninstall' ) uninstall;;
  'install'   ) install;;
  *           ) install;;
esac
