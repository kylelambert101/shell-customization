#!/usr/bin/env bash

# Load this file from ~/.bashrc by adding the following line
# source <path-to-custom-functions-repo>/source-me.bash

# Get the location of this file from the command args
DIR=$(dirname $0)

source "$DIR/GeneralFunctions.bash"
source "$DIR/GitFunctions.bash"
source "$DIR/DotnetFunctions.bash"
source "$DIR/KubeFunctions.bash"
