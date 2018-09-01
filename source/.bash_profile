platform=$(uname)

shopt -s checkwinsize

bind Space:magic-space

BLK_CLR="\[$(tput setaf 0)\]"
RED_CLR="\[$(tput setaf 1)\]"
GRN_CLR="\[$(tput setaf 2)\]"
YLW_CLR="\[$(tput setaf 3)\]"
BLU_CLR="\[$(tput setaf 4)\]"
PPL_CLR="\[$(tput setaf 5)\]"
CYN_CLR="\[$(tput setaf 6)\]"
WHT_CLR="\[$(tput setaf 7)\]"
DIM_CLR="\[\e[2m\]"
NON_CLR="\[\e[0m\]"
PS1_CLR="$BLU_CLR"

export SUCCESS_CHAR="✔"
export FAILURE_CHAR="✘"
export PROMPT_CHAR="➜"
export PROMPT_CONT="·"

export PS1="${PS1_CLR}${PROMPT_CHAR}${NON_CLR} "
export PS2="${PS1_CLR}${PROMPT_CONT}${NON_CLR} "

export HISTCONTROL=ignoredups:ignorespace

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_STATESEPARATOR=':'

__prompt_time() {
    # Looks wacky when the screen is resized.
    # echo "${WHT_CLR}\[\e[s\]\[\e[\$((COLUMNS-5))C\]\$(date +%H:%M)\[\e[u\]${NON_CLR}"
    echo " ${CYN_CLR}at${NON_CLR} ${CYN_CLR}$(date +%H:%M)${NON_CLR}"
}

__prompt_user() {
    echo "${GRN_CLR}\u${NON_CLR}"
}

__prompt_host() {
    echo " ${CYN_CLR}on${NON_CLR} ${PPL_CLR}\h${NON_CLR}"
}

__prompt_path() {
    echo " ${CYN_CLR}in${NON_CLR} ${BLU_CLR}$(__prompt_cwd)${NON_CLR}${CYN_CLR}$(__prompt_branch)$(__prompt_venv)${NON_CLR}"
}

__prompt_cwd() {
    if (( $COLUMNS >= 100 ))
    then
        echo "\w"
    else
        echo "\W"
    fi
}

__prompt_branch() {
    echo "$(__git_ps1 " [%s]" 2> /dev/null)"
}

__prompt_venv() {
    if [[ $VIRTUAL_ENV != '' ]]; then
        echo " ($(basename "$VIRTUAL_ENV"))"
    fi
}

__prompt_status() {
    if test $STATUS -eq 0
    then
        echo "${GRN_CLR}${SUCCESS_CHAR}${NON_CLR}"
    else
        echo "${RED_CLR}${FAILURE_CHAR}${NON_CLR}"
    fi
}

__prompt() {
    export STATUS=$?
    export PS1="$(__prompt_user)$(__prompt_host)$(__prompt_path)$(__prompt_time)\n$(__prompt_status) "
    export PS2="${PROMPT_CONT} "
}

export PROMPT_COMMAND=__prompt

export EDITOR='vim'
# export GOPATH='/Users/mtarbit/projects/_learning/go'
# export CDPATH="$CDPATH:~/projects"
export PATH="$PATH:$(go env GOPATH)/bin"

if [ -r "$(brew --prefix)/etc/bash_completion" ]; then
    . "$(brew --prefix)/etc/bash_completion"
fi

if [[ $platform == 'Linux' ]]; then

    alias 'ls'='ls -hpA --color=auto'
    alias 'open'='gnome-open'
    # alias 'mduml'='~/MagicDraw_Reader/bin/mduml'
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
    alias 'chrome'='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
    export PATH="$PATH:~/bin"
    # export PATH="$PATH:~/bin:/usr/local/mysql/bin"
    # export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:/usr/local/mysql/lib"

fi

alias 'll'='ls -l'
alias 'ack'='ack --color-filename=green --color-match=yellow --ignore-file=ext:pyc'
alias 'tmux'='tmux -2'
alias 'dateslug'='date +"%Y-%m-%d.%I-%M"'
alias 'whats-my-ip'='dig +short myip.opendns.com @resolver1.opendns.com'
alias 'docker-exec'='docker-compose exec'
alias 'docker-run'='docker-compose run --rm'
alias 'docker-django'='docker-run web python manage.py'

docker-logs() {
    docker-compose logs -f --tail=$(tput lines) "$1" | less -RS +F
}

ansi-colors() {
    for i in {0..3}; do
        for j in {30..37}; do
            for k in {40..47}; do
                echo -ne "\033[${i};${j};${k}m${i};${j};${k}\033[m "
            done
            echo
        done
    done
}

listening() {
    if [ -z "$1" ]; then

        lines=$(sudo lsof -P -s TCP:LISTEN -i TCP | tail -n +2)
        pairs=$(echo -n "$lines" | awk '{split($9,a,":"); print $2":"a[2]}' | uniq)
        format_string="%5s %5s %s\n"

        if [ -n "$pairs" ]; then
            printf "$format_string" "PORT" "PID" "COMMAND"
            for pair in $pairs; do
                port="${pair/#*:}"
                proc="${pair/%:*}"
                cmnd="$(ps -p "$proc" -o command=)"

                printf "$format_string" "$port" "$proc" "${cmnd:0:$COLUMNS-12}"
            done
        fi

    else

        pid=$(lsof -P -s TCP:LISTEN -i TCP:"$1" -t | uniq)
        if [ -n "$pid" ]; then
            ps -p "$pid" -o pid,command
        fi

    fi
}

generate-pass() {
    length=${1:-16}
    LC_ALL=C tr -cd '[:alnum:]' < /dev/urandom | fold -w${length} | head -n1
}

generate-md5s() {
    number=${1:-1}
    length=${2:-32}
    LC_ALL=C tr -cd '[:xdigit:]' < /dev/urandom | tr '[:upper:]' '[:lower:]' | fold -w${length} | head -n${number}
}

rust-run() {
    rustc "$1.rs" --out-dir=/Users/mtarbit/tmp/rust-learning/bin && /Users/mtarbit/tmp/rust-learning/bin/"$1"
}

# # As instructed in rvm installer instructions:
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Or use rbenv if it's available:
# if [[ -s "$HOME/.rbenv/bin" ]]; then
#     export PATH="$HOME/.rbenv/bin:$PATH"
#     eval "$(rbenv init -)"
# fi

eval "$(rbenv init -)"

# ### Added by the Heroku Toolbelt
# export PATH="/usr/local/heroku/bin:$PATH"

# Added by the Rust installer on 2018-08-05.
export PATH="$HOME/.cargo/bin:$PATH"
