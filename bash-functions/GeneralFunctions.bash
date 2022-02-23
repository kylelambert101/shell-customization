#!/usr/bin/env bash

# Print a command to the console before running it
showAndRun(){
    printf ">> %s\n" "$*"
    $@
}

# list PATH on separate lines, optionally sorted with "-s" flag
path(){
    if [[ "$1" == "-s" ]]; then
        echo "${PATH//:/$'\n'}" | sort
    else
        echo "${PATH//:/$'\n'}"
    fi
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


alias kp="killPorts"
alias pk="killPorts"
alias leave="exit 0"
