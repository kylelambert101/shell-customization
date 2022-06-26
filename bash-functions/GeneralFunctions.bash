#!/usr/bin/env bash

# Print a command to the console before running it
showAndRun(){
    printf ">> %s\n" "$*"
    $@
}

# list PATH on separate lines, optionally sorted with "-s" flag
path(){
    local NEWLINE=$'\n'
    if [[ "$1" == "-s" ]]; then
        echo "${PATH//:/$NEWLINE}" | sort
    else
        echo "${PATH//:/$NEWLINE}"
    fi
}

# Wrapper for find...grep style searches which ignores node_modules and shows matching files in blue
ffind(){
    local DIR="$1"
    local FILEPATTERN="$2"
    local TARGET="$3"

    local BLUE=$(tput setaf 4)
    local NORMAL=$(tput sgr0)

    find $DIR -name *node_modules* -prune -o \
        -type f -name $FILEPATTERN \
        -exec printf "${BLUE}{}${NORMAL}\n" \; \
        -exec grep -ni $TARGET {} \;
}

# Kill the process(es) running on port(s) $@
killPorts(){
    if [[ ! $(command -v "kill-port") ]]; then
        printf "kill-port is not installed. To install globally:\n\n"
        printf "    npm i -g kill-port\n"
        return
    fi
    
    kill-port "$@"
}

# Navigate to specified directory and open VS Code
cdCode(){
    cd "$1"
    code .
}


alias kp="killPorts"
alias pk="killPorts"
alias leave="exit 0"
alias ccode="cdCode"
