
# ==============================================================================
# ~/.bash_profile vs. ~/.bashrc
# ==============================================================================

# See notes in .bash_profile. The separation is necessary so that these aliases
# and commands are available to interactive non-login shells, such as child bash
# processes and vim's :terminal window.


# ==============================================================================
# Prompt command
# ==============================================================================

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

SUCCESS_CHAR="✔"
FAILURE_CHAR="✘"
PROMPT_CHAR="➜"
PROMPT_CONT="·"

__prompt_title() {
    # https://wiki.archlinux.org/title/Bash/Prompt_customization#Bash_escape_sequences
    # https://serverfault.com/questions/23978/how-can-one-set-a-terminals-title-with-the-tput-command

    # The `tput tsl` call here returns `\e]2;` which works in Kitty but not iTerm.
    # Not sure why that is, but I found this `\e]0;` version in the default Ubuntu
    # .bashrc and it seems to work in both.

    # TODO: It looks like it's possible to use something like this with $PS0 to show
    # the current command in the terminal tab or window title. See here for details:
    # ${KITTY_INSTALLATION_DIR}/shell-integration/bash/kitty.bash
    # We're not just using kitty's default shell integration for this since it shows
    # the full pwd path and we just want the shorter basename.

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


# ==============================================================================
# Aliases
# ==============================================================================

if [[ -r "$(brew --prefix)/etc/bash_completion" ]]; then
    # . "$(brew --prefix)/etc/bash_completion"
    . "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh"
    . "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
fi

if [[ $(uname) == 'Darwin' ]]; then
    alias 'ls'='ls -hpAG'
    alias 'firefox'='/Applications/Firefox.app/Contents/MacOS/firefox'
    alias 'chrome'='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
else
    alias 'ls'='ls -hpA --color=auto'
    alias 'open'='gnome-open'

    if [[ -n $DISPLAY ]]; then
        setxkbmap -option "caps:escape"
    fi
fi

alias 'll'='ls -l'
alias 'ack'='ack --color-filename=green --color-match=yellow --ignore-file=ext:pyc'
alias 'tmux'='tmux -2'
alias 'date-slug'='date +"%Y-%m-%d"'
alias 'date-time-slug'='date +"%Y-%m-%d_%H-%M"'
alias 'internal-ip'='ipconfig getifaddr en0'
alias 'external-ip'='dig +short myip.opendns.com @resolver1.opendns.com'
alias 'whats-my-ip'='external-ip'
alias 'docker-exec'='docker-compose exec'
alias 'docker-run'='docker-compose run --rm'
alias 'docker-django'='docker-run web python manage.py'

# A compromise for kitty. The official line is that users should alias
# this command to `kitty +kitten ssh <server-name>` to copy terminfo
# files to the server, but that isn't so helpful if you're likely to be
# switching to a different account after connecting. So just announce
# ourselves as a vaguely similar supported TERM type instead.
alias 'ssh'='TERM=xterm-256color ssh'


# ==============================================================================
# Functions
# ==============================================================================

# docker-logs() {
#     docker-compose logs -f --tail=$(tput lines) "$1" | less -RS +F
# }

ansi-colors() {
    for i in {0..3}; do # Style
        for j in {30..37}; do # Foreground color
            for k in {40..47}; do # Background color
                echo -ne "\033[${i};${j};${k}m${i};${j};${k}\033[m "
                # echo -ne "\033[${j};${k}m${j};${k}\033[m "
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
    # See: https://unix.stackexchange.com/a/715405
    local getopt_dir getopt_tmp special=0

    getopt_dir="$(brew --prefix)/opt/gnu-getopt/bin/"
    getopt_tmp=$("${getopt_dir}/getopt" -o 's' --long 'special' -n "$FUNCNAME" -- "$@")

    [ $? -ne 0 ] && return 1

    eval set -- "$getopt_tmp"

    while true; do
        case "$1" in
            '-s'|'--special')
                special=1
                shift
                ;;
            '--')
                shift
                break
                ;;
        esac
    done

    length=${1:-24}
    tr_str='[:alnum:]'

    if [ $special -ne 0 ]; then
        tr_str="${tr_str}[:punct:]"
    fi

    LC_ALL=C tr -cd "${tr_str}" < /dev/urandom | fold -w${length} | head -n1
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

man-opt() {
    # Open the man page for a command and jump to a particular option.
    # Note that `less -is` is default man pager according to `man man`.
    # Use: `man-opt <command> <option>`
    # e.g: `man-opt tar -t`
    man -P "less -is -p '^ +${2}'" "${1}";
}

# usr-include-path() {
#     echo "$(xcrun --show-sdk-path)/usr/include"
# }

# dict() {
#     open "dict://${1}"
# }

# brew-installed() {
#     brew info "${1}" | \
#     grep "Not installed" > /dev/null \
#     && echo "not-installed" \
#     || echo "installed"
# }

# ssl-fingerprint() {
#     openssl x509 -noout -serial -in $1 | cut -d'=' -f2 | sed 's/../&:/g; s/:$//' # | tr '[:upper:]' '[:lower:]'
# }

# init-cpp-exercise() {
#     dir_name=$PWD
#     dir_name=${dir_name##*/}
#     dir_name=${dir_name//-/_}
#     touch "$dir_name".{h,cpp}
#     mkdir build
#     cmake -G "Unix Makefiles" -B build
# }

# test-cpp-exercise() {
#     make -C build
# }

# convert-video() {
#     file=$1
#     width=1280
#     ffmpeg -i "${file}" \
#         -codec:v h264 -codec:a aac \
#         -filter:v scale=${width}:-2 \
#         -profile:v baseline -level 3.0 \
#         -pix_fmt yuv420p \
#         -movflags +faststart \
#         -y "${file%.*}.new.mp4"
# }


# ==============================================================================
# Project layouts (for Kitty)
# ==============================================================================

PROJECT_DIR=~/.config/kitty/projects
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
