# KPL-Modded version of Michele Bologna's theme
# https://www.michelebologna.net
#
# This a theme for oh-my-zsh. 
#
# git prompt is inspired by official git contrib prompt:
# https://github.com/git/git/tree/master/contrib/completion/git-prompt.sh
# and it adds:
# * the current branch
# * '%' if there are untracked files
# * '$' if there are stashed changes
# * '*' if there are modified files
# * '+' if there are added files
# * '<' if local repo is behind remote repo
# * '>' if local repo is ahead remote repo
# * '=' if local repo is equal to remote repo (in sync)
# * '<>' if local repo is diverged
#

# Updated KPL-Modded zsh theme to match Git Bash prompt format

local green="%{$FG[010]%}"
local red="%{$fg[red]%}"
local cyan="%{$fg[cyan]%}"
local yellow="%{$fg[yellow]%}"
local blue="%{$fg[blue]%}"
local magenta="%{$fg[magenta]%}"
local white="%{$fg[white]%}"
local reset="%{$reset_color%}"

# Custom Colors. For more, run zsh ~/.oh-my-zsh/lib/spectrum.zsh && spectrum_ls
local orange="%{$FG[172]%}"
local bluish="%{$FG[027]%}"
local purplish="%{$FG[063]%}"
local bluegreen="%{$FG[042]%}"
local yellowish="%{$FG[226]%}"
local pinkish="%{$FG[013]%}"

local username_command="%n"
local hostname_command="%m"
local current_dir="%~"

local username_output="$bluish$username_command$reset"
local hostname_output="$bluegreen@$hostname_command$reset"
local current_dir_output="$yellowish$current_dir$reset"

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_UNTRACKED="$pinkish--"
ZSH_THEME_GIT_PROMPT_MODIFIED="$pinkish*"
ZSH_THEME_GIT_PROMPT_ADDED="$pinkish+"
ZSH_THEME_GIT_PROMPT_STASHED="$pinkish$"
ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE="$pinkish="
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="$pinkish>"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="$pinkish<"
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="$red<>"

NEWLINE=$'\n'
PROMPT_SYMBOL=""
GIT_PROMPT='$(out=$(git_prompt_info)$(git_prompt_status)$(git_remote_status);if [[ -n $out ]]; then printf %s " $white($cyan$out$white)$reset";fi)'

PROMPT="$NEWLINE\${purplish}[\$(date +%F_%T)]\${reset} $username_output$hostname_output $current_dir_output$GIT_PROMPT"
PROMPT+="$white$NEWLINE>> $reset"
RPROMPT=''
