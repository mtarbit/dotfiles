Dotfiles
========

A selection of .file configuration from my home directories. I previously kept this stuff in sync across multiple machines with Dropbox, just trying this out as an alternative.

### Usage

If adapting for your own use, add your dotfiles to `/source` and list them in the `Manifest`.

    $ bootstrap.sh --help
    Usage: bootstrap.sh [<command>] [-d|--dry-run]
    Where <command> is 'install', 'uninstall' or 'update'.

The 'install' command creates symlinks in your `$HOME` directory for the paths listed in the Manifest, 'uinstall' removes them, and 'update' is yet to be written.

### Acknowledgments

The symlinking script was heavily inspired by / shamelessly ganked from [sensae/dotfiles](http://www.github.com/sensae/dotfiles). It just didn't seem right to fork, since the dotfiles themselves are all mine, and I've modified the script a fair bit.
