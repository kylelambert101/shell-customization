# Automatically set the upstream branch for the current local branch
gitup() {
    # Assume we're using the standard "origin" name for remote
    local REMOTE="origin"
    printf "Determining branch... "
    local BRANCH=$(git branch --show-current)
    printf "'%s'\n" "$BRANCH"
    printf "Determining HEAD branch... "
    local HEADBRANCH=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
    printf "'%s'\n" "$HEADBRANCH"
    if [[ -z "$BRANCH" ]]; then
        echo "No branch found. Aborting."
        return
    fi
    if [[ "$BRANCH" == "$HEADBRANCH" ]]; then
        echo "On branch $HEADBRANCH. Aborting."
        return
    fi
    echo "Running \`git push --set-upstream $REMOTE $BRANCH\`"
    git push --set-upstream "$REMOTE" "$BRANCH"
}

# Show the ten most recently checked out git branches for the current repo
showRecentGitBranches(){
    printf "Determining repo... "
    local THIS_REPO=$(git config --get remote.origin.url)
    printf "'%s'\n" $THIS_REPO
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
    printf "Determining HEAD branch... "
    local HEADBRANCH=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
    printf "'%s'\n" $HEADBRANCH
    showAndRun git checkout $HEADBRANCH
    showAndRun git pull origin $HEADBRANCH
}

# Try merging HEAD into current branch
gitMergeHead(){
    if [[ $(git diff --stat) != '' ]]; then
        printf "\n"
        printf "!! Dirty git state detected. Please commit or stash changes before proceeding.\n"
        return
    fi  

    printf "Fetching repository info...\n"
    if [[ $(git config --get remote.origin.url) == "" ]]
    then
        printf "No remote git repo found. Aborting.\n"
        return
    fi

    printf "Determining branch... "
    local BRANCH=$(git branch --show-current)
    printf "'%s'\n" $BRANCH
    printf "Determining HEAD branch... "
    local HEADBRANCH=$(git remote show origin | grep "HEAD branch" | awk '{print $3}')
    printf "'%s'\n" $HEADBRANCH
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
    
    showAndRun git pull origin $HEADBRANCH

    if ! showAndRun git merge origin $HEADBRANCH
    then
        printf "Automatic merge failed; Opening VSCode to fix conflicts..."
        code .
        return
    fi

    printf "Done.\n\n"
    printf "Make sure to run \`git push\` if the local changes are satisfactory. " 
}

# Show a list of local branches configured with a remote branch that no longer exists
gitListLocal(){
    local BRANCHES
    
    BRANCHES=$(git fetch -p ; git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}')

    if [[ $BRANCHES == "" ]]; then
        echo "No untracked branches"
        return
    fi

    echo "$BRANCHES"
}

# Show a list of local branches that were never pushed to origin
gitListUntracked(){
    local BRANCHES
    
    BRANCHES=$(git branch --format "%(refname:short) %(upstream)" | awk '{if (!$2) print $1;}')

    if [[ $BRANCHES == "" ]]; then
        echo "No untracked branches"
        return
    fi

    echo "$BRANCHES"
}

gitListReleases(){
    local RELEASES
    
    RELEASES=$(git fetch && git branch -a | grep -oP "remotes/origin/release/\K\d+\.\d+\.\d+" | sort -t. -k1,1n -k2,2n -k3,3n | sed 's/^/release\//')

    if [[ $RELEASES == "" ]]; then 
        echo "No release branches"
        return
    fi

    echo "$RELEASES"
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
    elif [[ $@ == "releases" ]]; then
        gitListReleases
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

alias glo='git --no-pager log --oneline -n 10'
alias gpm='gitPullHead'
alias gph='gitPullHead'
alias gmm='gitMergeHead'
alias gmh='gitMergeHead'
alias gll='gitListLocal'
alias glu='gitListUntracked'
