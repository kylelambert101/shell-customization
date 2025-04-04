#!/usr/bin/env bash

# Load this file from ~/.bashrc by adding the following line
# source <path-to-custom-functions-repo>/source-me.bash

if [[ $OSTYPE == 'msys'* ]]; then   
    # Windows
    DIR="${BASH_SOURCE%/*}"
    if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
else
    # MacOS/Linux
    DIR=$(dirname "$0")
fi

if [[ $DIR != "" ]]; then
    source "$DIR/GeneralFunctions.bash"
    source "$DIR/GitFunctions.bash"
    source "$DIR/DotnetFunctions.bash"
    source "$DIR/KubeFunctions.bash"
fi
