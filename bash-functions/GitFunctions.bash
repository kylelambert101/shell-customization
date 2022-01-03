#!/usr/bin/env bash

# Automatically set the upstream branch for the current local branch
gitup() {
    # Assume we're using the standard "origin" name for remote
    local REMOTE="origin"
    local BRANCH=$(git branch --show-current)
    local HEADBRANCH=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
    if [[ $BRANCH == "" ]]
    then
        echo "No branch found. Aborting."
        return
    fi
    if [[ $BRANCH == $HEADBRANCH ]]
    then
        echo "On branch $HEADBRANCH. Aborting."
        return
    fi
    local CMD="git push --set-upstream $REMOTE $BRANCH"
    echo "Running \`$CMD\`"
    $CMD
}

# Show the ten most recently checked out git branches for the current repo
showRecentGitBranches(){
    local THIS_REPO=$(git config --get remote.origin.url)
    if [[ $THIS_REPO == "" ]]
    then
        echo "No git repo found. Aborting."
        return
    fi
    if [ ! -f ~/.git_branch_history ]; then
        echo "No history file found. Aborting"
        return
    fi
    local RESULTS=()
    while IFS=, read -r DATE REPO BRANCH ; do
        # Skip the header line
        if [[ "$DATE" != "Date" ]]; then
            # Collect results if the repo matches and branch hasn't been reported yet
            if [[ "$REPO" == "$THIS_REPO" ]] && [[ ! " ${RESULTS[@]} " =~ " ${BRANCH} " ]]; then
                RESULTS+=( "[$DATE] $BRANCH" )
            fi
        fi
    done < <(tac ~/.git_branch_history)
    
    echo "Last Accessed         Branch"
    for i in ${!RESULTS[@]}; do
       echo ${RESULTS[$i]}
    # Flip to be chronologically ordered and limit to 10 results
    done | tac | tail -10
}

# Check out and pull HEAD branch
gitPullHead(){
    local HEADBRANCH=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
    showAndRun "git checkout $HEADBRANCH"
    showAndRun "git pull origin $HEADBRANCH"
}

# Try merging HEAD into current branch
gitMergeHead(){
    if [[ $(git diff --stat) != '' ]]; then
        printf "\n"
        printf "!! Dirty git state detected. Please commit or stash changes before proceeding.\n"
        exit 1
    fi  

    printf "Fetching repository info...\n"
    if [[ $(git config --get remote.origin.url) == "" ]]
    then
        printf "No remote git repo found. Aborting.\n"
        return
    fi

    local HEADBRANCH=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
    local BRANCH=$(git branch --show-current)
    printf "\n"
    printf "HEAD branch:    $HEADBRANCH\n"
    printf "Current branch: $BRANCH\n"
    printf "\n"

    if [[ $HEADBRANCH == "" ]]
    then
        printf "No HEAD branch found. Aborting.\n"
        return
    fi
    if [[ $BRANCH == "" ]]
    then
        # "Detached HEAD" state from checking out a commit
        printf "Not on a branch. Aborting.\n"
        return
    elif [[ $BRANCH == $HEADBRANCH ]]
    then
        printf "Already on $HEADBRANCH branch. Aborting.\n"
        return
    fi
    
    showAndRun "git checkout $HEADBRANCH"
    showAndRun "git pull origin $HEADBRANCH"
    showAndRun "git checkout $BRANCH"

    printf "\n"
    if ! showAndRun "git merge $HEADBRANCH"
    then
        printf "Automatic merge failed; Opening VSCode to fix conflicts..."
        code .
        return
    fi

    printf "Done.\n\n"
    printf "Make sure to run \`git push\` if the local changes are satisfactory. " 
}

# override git command with custom functionality
git(){
    # show recent branches with "git rb"
    if [[ $@ == "rb" ]]; then
        showRecentGitBranches
    # Set the upstream branch with "git up"
    elif [[ $@ == "up" ]]; then
        gitup
    # Check out and pull HEAD branch
    elif [[ $@ == "pullm" ]]; then
        gitPullHead
    # Perform automatic merge with HEAD branch
    elif [[ $@ == "mergem" ]]; then
        gitMergeHead
    else
        command git "$@"
        if [[ $1 == "checkout" ]]; then
            # Log this checkout to the branch history
            if [ ! -f ~/.git_branch_history ]; then
                echo "Date,Repository URL,Branch" >> ~/.git_branch_history
            fi
            local BRANCH=$(git branch --show-current)
            local REPO=$(git config --get remote.origin.url)
            local DATE=$(date '+%Y-%m-%d %H:%M:%S')
            if [[ $BRANCH == "" ]]
            then
                # "Detached HEAD" state from checking out a commit - use () placeholder. 
                BRANCH="()"
            fi
            echo "$DATE,$REPO,$BRANCH" >> ~/.git_branch_history
        fi
    fi
}

alias glo='git log --oneline -n 10'
alias gpm='gitPullHead'
alias gph='gitPullHead'
alias gmm='gitMergeHead'
alias gmh='gitMergeHead'