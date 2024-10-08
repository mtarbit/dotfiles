
# ==============================================================================
# ~/.bash_profile vs. ~/.bashrc
# ==============================================================================

# The .bash_profile is sourced by interactive login shells, while .bashrc is
# sourced by interactive non-login shells. This means that any aliases and
# function definitions can appear there and be sourced here so they're
# available to both kinds of shell, but any exported variables should only
# appear here since they'll be inherited by non-login child shells.

# Also note that any $PATH adjustments must only happen here and not in .bashrc
# otherwise they'll be repeated every time a child shell is spawned.

# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html


# ==============================================================================
# Homebrew config
# ==============================================================================

eval "$(/opt/homebrew/bin/brew shellenv)"

# A probably temporary alias and fallback dynamic library path for
# use while migrating from x86_64 brew to arm64 brew.
alias 'ibrew'='/usr/local/bin/brew'

# Note: This was specifically added because some pypi packages, like filemagic,
# use `ctypes.util.find_library()` to get a .dylib path, and it was returning
# the x86_64 `/usr/local/lib` library path instead of the arm path below.
#
# (Doesn't work though because macOS's new SIP protections strip any DYLD_* env
# vars when spawning a child process)
# export DYLD_FALLBACK_LIBRARY_PATH='/opt/homebrew/lib'
#
# This issue is discussed here:
# - https://github.com/orgs/Homebrew/discussions/3424#discussioncomment-3131452
# - https://github.com/pyenv/pyenv/issues/2339
#
# The last comment proposes a hacky fix of symlinking /opt/homebrew/lib to ~/lib
# which is what I've done for now.


# ==============================================================================
# Aliases and functions
# ==============================================================================

[[ -f ~/.bashrc ]] && source ~/.bashrc


# ==============================================================================
# Shell config
# ==============================================================================

# Check the window size after each command and update
# the values of $LINES and $COLUMNS if necessary.
shopt -s checkwinsize

# Do inline auto-expansion of history substitutions
# like `!!` when they are followed by a space.
bind Space:magic-space

# Disable start/stop output control (usually Ctrl-S),
# to allow searching back and forth through command
# history with Ctrl-R and Ctrl-S.
stty -ixon

export HISTCONTROL=ignoredups:ignorespace

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_STATESEPARATOR=':'

export PS1="${PS1_CLR}${PROMPT_CHAR}${NON_CLR} "
export PS2="${PS1_CLR}${PROMPT_CONT}${NON_CLR} "
export PROMPT_COMMAND=__prompt

export EDITOR='vim'


# ==============================================================================
# Other config
# ==============================================================================

# Don't timeout `pass -c` so quickly (see `$(brew --prefix)/bin/pass`).
# This timeout matches the cache-ttl in `.gnupg/gpg-agent.conf`.
export PASSWORD_STORE_CLIP_TIME=7200


# ==============================================================================
# Paths (and setup for env managers)
# ==============================================================================

export CDPATH="$CDPATH:.:~:~/projects:~/projects/_freelance/shadow-server"

# Not using these at the moment and `npm bin` is slow.
# export GOPATH='/Users/mtarbit/projects/_learning/go'
# export PATH="${PATH}:~/bin"
# export PATH="${PATH}:$(go env GOPATH)/bin
# export PATH="${PATH}:$(npm bin)"

# # As instructed in rvm installer instructions:
# if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
#   source "$HOME/.rvm/scripts/rvm"
# fi

# Or use rbenv if it's available:
# if [[ -s "$HOME/.rbenv/bin" ]]; then
#     export PATH="$HOME/.rbenv/bin:$PATH"
#     eval "$(rbenv init -)"
# fi

# eval "$(rbenv init -)"

# Added as instructed by pyenv docs (after `brew install pyenv`).
# https://github.com/pyenv/pyenv#basic-github-checkout
if command -v pyenv 1>/dev/null 2>&1; then

    # Trying to speed up time-to-prompt in bash. See:
    # https://github.com/pyenv/pyenv/issues/784
    # https://github.com/pyenv/pyenv#advanced-configuration
    #
    # # export PYENV_DEBUG=1
    # # eval "$(pyenv init --path)"
    # # eval "$(pyenv init -)"

    eval "$(pyenv init --no-rehash --path)"
fi

# ### Added by the Heroku Toolbelt
# export PATH="/usr/local/heroku/bin:$PATH"

# Added by the Rust installer on 2018-08-05.
export PATH="$HOME/.cargo/bin:$PATH"

# Removed because I'm installing mysql 8 and mysql 5 side-by-side
# now since we'll be migrating to 8 on any ubuntu 22 deploy envs.

# That means that I should use `brew unlink` and `brew link` to
# change which `mysql` is used, instead of editing the $PATH.

# # Include keg-only brew mysql in path on 2020-11-14
# # (need to specify paths to mysql because the default brew mysql is
# # now 8.0 which doesn't match what I need to use for some projects)
# export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
