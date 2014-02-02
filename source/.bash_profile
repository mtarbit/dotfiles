platform=$(uname)

shopt -s checkwinsize

bind Space:magic-space

RED_CLR="\[\e[0;31m\]"
GRN_CLR="\[\e[0;32m\]"
YLW_CLR="\[\e[0;33m\]"
BLU_CLR="\[\e[0;34m\]"
PPL_CLR="\[\e[0;35m\]"
CYN_CLR="\[\e[0;36m\]"
WHT_CLR="\[\e[0;37m\]"
NON_CLR="\[\e[0m\]"

PS1_CLR="$BLU_CLR"

export FAILURE_CHAR="✘"
export SUCCESS_CHAR="✔"
export PROMPT_CHAR="⚡"
export PROMPT_CHAR="➜"
export PROMPT_CONT="."

export PS1="${PS1_CLR}$PROMPT_CHAR $NON_CLR"
export PS2="${PS1_CLR}$PROMPT_CONT $NON_CLR "

export HISTCONTROL=ignoredups:ignorespace

__prompt_colour() {
    # Doesn't work because root shell doesn't run this file.
    if [ $(id -u) -eq 0 ]; then
        echo $RED_CLR
    else
        echo $BLU_CLR
    fi
}

__prompt_date() {
    # Looks wacky when the screen is resized.
    echo "$WHT_CLR\[\e[s\]\[\e[\$((COLUMNS-5))C\]\$(date +%H:%M)\[\e[u\]$NON_CLR"
}

__prompt_branch() {
    echo "$(__git_ps1 " $YLW_CLR[%s]$NON_CLR" 2> /dev/null)"
}

__prompt_venv() {
    if [[ $VIRTUAL_ENV != '' ]]; then
        echo " $YLW_CLR($(basename "$VIRTUAL_ENV"))$NON_CLR"
    fi
}

__prompt_status() {
    if test "$?" -eq 0
    then
        echo "$BLU_CLR$SUCCESS_CHAR$NON_CLR"
    else
        echo "$RED_CLR$FAILURE_CHAR$NON_CLR"
    fi
}

__prompt() {
    export STATUS_CHAR="$(__prompt_status)"
    export PS1="$(__prompt_date)$(__prompt_colour)\u$NON_CLR on $GRN_CLR\h$NON_CLR in $PPL_CLR\w$NON_CLR$(__prompt_branch)$(__prompt_venv)\n$(__prompt_colour)$STATUS_CHAR $NON_CLR"
    export PS2="$(__prompt_colour)$PROMPT_CONT $NON_CLR "
}

export PROMPT_COMMAND=__prompt

export PATH="$PATH:."
export EDITOR='vim'
# export CDPATH="$CDPATH:~/projects"

if [ -r /etc/bash_completion ]; then
    . /etc/bash_completion
fi

if [[ $platform == 'Linux' ]]; then

    alias 'ls'='ls -hpA --color=auto'
    alias 'open'='gnome-open'
    alias 'mduml'='~/MagicDraw_Reader/bin/mduml'
    export PATH="$PATH:~/bin"

    if [[ -n $DISPLAY ]]; then
        setxkbmap -option "caps:escape"
    fi

    # Terminator's window titles get filled with cruft.
    # This is an attempt to keep them clean and useful.

    # setWindowTitle() {
    #     echo -ne "\e]2;$*\a"
    # }

    # updateWindowTitle() {
    #     successPrompt
    #     setWindowTitle "${HOSTNAME%%.*} : ${PWD/HOME/~}"
    # }

    # PROMPT_COMMAND=updateWindowTitle

else

    alias 'ls'='ls -hpAG'
    export PATH="$PATH:~/bin:/usr/local/mysql/bin"
    export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:/usr/local/mysql/lib"

fi

alias 'll'='ls -l'
alias 'la'='ll'
alias 'ack'='ack -a --color-filename=green --color-match=yellow --ignore-dir=log --ignore-dir=tmp'
alias 'tmux'='tmux -2'

mkcd() { mkdir -p "${@}" && cd "${1}"; }

# As instructed in rvm installer instructions:
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Or use rbenv if it's available:
if [[ -s "$HOME/.rbenv/bin" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
