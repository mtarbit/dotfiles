Dotfiles
========

A selection of .file configuration from my home directories. I previously kept this stuff in sync across multiple machines with Dropbox, just trying this out as an alternative.

### Bootstrap usage

If adapting for your own use, add dotfiles to `/source` and list them in the `Manifest`.

    $ bootstrap.sh --help
    Usage: bootstrap.sh [<command>] [-d|--dry-run]
    Where <command> is 'install', 'uninstall' or 'update'.

### Bootstrap commands

 * __install__  Creates symlinks in your `$HOME` directory for the paths listed in the Manifest, and initializes and updates any git submodules (used here for vim bundles).
 * __uinstall__ Removes symlinks from your `$HOME` directory for the paths listed in the Manifest.
 * __update__ Still to be written.

### Acknowledgments

The symlinking script was heavily inspired by / shamelessly ganked from [sensae/dotfiles](http://www.github.com/sensae/dotfiles). It just didn't seem right to fork, since the dotfiles themselves are all mine, and I've modified the script a fair bit.
