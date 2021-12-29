#!/usr/bin/env bash

# override dotnet command with custom functionality
dotnet(){
    # Clear the nuget cache
    if [[ $@ == "clear" ]]; then
        showAndRun "dotnet nuget locals --clear all"
    else
        command dotnet "$@"
    fi
}