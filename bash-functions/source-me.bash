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
    source "$DIR/aws-functions.bash"
    source "$DIR/docker-functions.bash"
    source "$DIR/dotnet-functions.bash"
    source "$DIR/general-functions.bash"
    source "$DIR/git-functions.bash"
    source "$DIR/kube-functions.bash"
fi
