#!/usr/bin/env bash

# Print a command to the console before running it
showAndRun(){
    printf ">> %s\n" "$*"
    $@
}

# Kill the process that is taking up port $1
killPort(){
    local PORT=$1
    netstat -ano | findstr :$PORT | awk '{print $5}' | head -n 1 | xargs -t -n1 tskill
}


alias kp="killPort"
alias pk="killPort"
alias leave="exit 0"
