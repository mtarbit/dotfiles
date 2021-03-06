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

__prompt_title() {
    # https://wiki.archlinux.org/title/Bash/Prompt_customization#Bash_escape_sequences
    # https://serverfault.com/questions/23978/how-can-one-set-a-terminals-title-with-the-tput-command

    # The `tput tsl` call here returns `\e]2;` which works in Kitty but not iTerm.
    # Not sure why that is, but I found this `\e]0;` version in the default Ubuntu
    # .bashrc and it seems to work in both.

    # echo "\[$(tput tsl)\W$(tput fsl)\]"
    echo "\[\e]0;\W\a\]"
}

__prompt_user() {
    echo "${GRN_CLR}\u${NON_CLR}"
}

__prompt_host() {
    echo " ${CYN_CLR}on${NON_CLR} ${PPL_CLR}\h${NON_CLR}"
}

__prompt_path() {
    echo " ${CYN_CLR}in${NON_CLR} ${BLU_CLR}$(__prompt_path_cwd)${NON_CLR}${CYN_CLR}$(__prompt_path_branch)$(__prompt_path_venv)${NON_CLR}"
}

__prompt_path_cwd() {
    if (( $COLUMNS > 125 ))
    then
        echo "\w"
    else
        echo "\W"
    fi
}

__prompt_path_branch() {
    echo "$(__git_ps1 " [%s]" 2> /dev/null)"
}

__prompt_path_venv() {
    if [[ $VIRTUAL_ENV != '' ]]; then
        echo " ($(basename "$VIRTUAL_ENV"))"
    fi
}

__prompt_time() {
    # Looks wacky when the screen is resized.
    # echo "${WHT_CLR}\[\e[s\]\[\e[\$((COLUMNS-5))C\]\$(date +%H:%M)\[\e[u\]${NON_CLR}"
    echo " ${CYN_CLR}at${NON_CLR} ${CYN_CLR}$(date +%H:%M)${NON_CLR}"
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
    export PS1="$(__prompt_title)$(__prompt_user)$(__prompt_host)$(__prompt_path)$(__prompt_time)\n$(__prompt_status) "
    export PS2="${PROMPT_CONT} "
}

export PROMPT_COMMAND=__prompt

export EDITOR='vim'
# export GOPATH='/Users/mtarbit/projects/_learning/go'
export CDPATH="$CDPATH:.:~:~/projects:~/projects/_freelance/shadow-server"
export PATH="$PATH:$(go env GOPATH)/bin"

# Don't timeout `pass -c` so quickly (see /usr/local/bin/pass).
# This timeout matches the cache-ttl in `.gnupg/gpg-agent.conf`.
export PASSWORD_STORE_CLIP_TIME=7200

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
alias 'date-slug'='date +"%Y-%m-%d_%H-%M"'
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

generate-ips() {
    number=${1:-1}
    for i in $(seq 1 $number); do
        printf "%d.%d.%d.%d\n" "$((RANDOM % 256))" "$((RANDOM % 256))" "$((RANDOM % 256))" "$((RANDOM % 256))"
    done
}

fix-sound() {
    sudo pkill -f coreaudio[a-z]
}

usr-include-path() {
    echo "$(xcrun --show-sdk-path)/usr/include"
}

dict() {
    open "dict://${1}"
}

man-opt() {
    # Open the man page for a command and jump to a particular option.
    # Note that `less -is` is default man pager according to `man man`.
    # Use: `man-opt <command> <option>`
    # e.g: `man-opt tar -t`
    man -P "less -is -p '^ +${2}'" "${1}";
}

brew-installed() {
    brew info "${1}" | \
    grep "Not installed" > /dev/null \
    && echo "not-installed" \
    || echo "installed"
}

ssl-fingerprint() {
    openssl x509 -noout -serial -in $1 | cut -d'=' -f2 | sed 's/../&:/g; s/:$//' # | tr '[:upper:]' '[:lower:]'
}

rust-run() {
    rustc "$1.rs" --out-dir=/Users/mtarbit/tmp/rust-learning/bin && /Users/mtarbit/tmp/rust-learning/bin/"$1"
}

init-cpp-exercise() {
    dir_name=$PWD
    dir_name=${dir_name##*/}
    dir_name=${dir_name//-/_}
    touch "$dir_name".{h,cpp}
    mkdir build
    cmake -G "Unix Makefiles" -B build
}

test-cpp-exercise() {
    make -C build
}

convert-video() {
    file=$1
    width=1280
    ffmpeg -i "${file}" \
        -codec:v h264 -codec:a aac \
        -filter:v scale=${width}:-2 \
        -profile:v baseline -level 3.0 \
        -pix_fmt yuv420p \
        -movflags +faststart \
        -y "${file%.*}.new.mp4"
}


PROJECT_DIR='.config/kitty/projects'
PROJECT_EXT='.sh'

project() {
    path="${PROJECT_DIR}/${1}${PROJECT_EXT}"
    if [ -z "$1" ]; then
        echo "Project name not specified."
    elif [ ! -f "$path" ]; then
        echo "Profile file not found at:"
        echo "$path"
    else
        source "$path"
    fi
}

_project_complete() {
    # https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html
    # https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion-Builtins.html
    # https://www.gnu.org/software/bash/manual/html_node/A-Programmable-Completion-Example.html
    local current="$2"
    compopt -o nospace
    for project_file_path in $(compgen -f -- "${PROJECT_DIR}/${current}")
    do
        project_file=$(basename "$project_file_path")
        project_name="${project_file%$PROJECT_EXT}"
        COMPREPLY+=("$project_name")
    done
}

complete -F _project_complete project


# # As instructed in rvm installer instructions:
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Or use rbenv if it's available:
# if [[ -s "$HOME/.rbenv/bin" ]]; then
#     export PATH="$HOME/.rbenv/bin:$PATH"
#     eval "$(rbenv init -)"
# fi

eval "$(rbenv init -)"

# Added as instructed by pyenv docs (after `brew install pyenv`):
# https://github.com/pyenv/pyenv#basic-github-checkout
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# ### Added by the Heroku Toolbelt
# export PATH="/usr/local/heroku/bin:$PATH"

# Added by the Rust installer on 2018-08-05.
export PATH="$HOME/.cargo/bin:$PATH"

# Include keg-only brew mysql in path on 2020-11-14
# (need to specify paths to mysql because the default brew mysql is
# now 8.0 which doesn't match what I need to use for some projects)
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
