# KPL-Modded version of Michele Bologna's theme
# https://www.michelebologna.net
#
# This a theme for oh-my-zsh. Features a colored prompt with:
# * username@host: [jobs] [git] workdir %
# * hostname color is based on hostname characters. When using as root, the
# prompt shows only the hostname in red color.
# * [jobs], if applicable, counts the number of suspended jobs tty
# * [git], if applicable, represents the status of your git repo (more on that
# later)
# * '%' prompt will be green if last command return value is 0, yellow otherwise.
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
# KPL Additions:
# - Changed the prompt symbol to a tropical or puffer fish, depending on previous command success
# - Changed colors


#local green="%{$fg_bold[green]%}"
local green="%{$FG[010]%}"
local red="%{$fg_bold[red]%}"
local cyan="%{$fg_bold[cyan]%}"
local yellow="%{$fg_bold[yellow]%}"
local blue="%{$fg_bold[blue]%}"
local magenta="%{$fg_bold[magenta]%}"
local white="%{$fg_bold[white]%}"
local reset="%{$reset_color%}"

# Custom colors
# For more, run zsh ~/.oh-my-zsh/lib/spectrum.zsh && spectrum_ls
local orange="%{$FG[172]%}"
local bluish="%{$FG[027]%}"
local purplish="%{$FG[063]%}"
local bluegreen="%{$FG[042]%}"
local yellowish="%{$FG[226]%}"

local -a color_array
color_array=($green $red $cyan $yellow $blue $magenta $white)

local username_normal_color=$purplish
local username_root_color=$red
local hostname_root_color=$red

# calculating hostname color with hostname characters
for i in `hostname`; local hostname_normal_color=$color_array[$[((#i))%7+1]]
local -a hostname_color
hostname_color=%(!.$hostname_root_color.$hostname_normal_color)

local current_dir_color=$blue
local username_command="%n"
local hostname_command="%m"
local current_dir="%~"

local username_output="%(!..$username_normal_color$username_command$reset@)"
local hostname_output="$hostname_color$hostname_command$reset"
local current_dir_output="$current_dir_color$current_dir$reset"
local jobs_bg="${red}fg: %j$reset"
local last_command_output="%(?.%(!.$red.$green).$yellow)"

# I overthought this way too much. How to decorate the prompt with emoji?
# Some choices
# - alien_monster
# - blowfish
# - collision_symbol
# - alien
# - raised_hand_with_fingers_splayed
# - robot_face
# - rocket
# - snail
# - tropical_fish
# - white_right_pointing_backhand_index
# Full list: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/emoji/emoji-char-definitions.zsh
local prompt_based_on_last_command="%(?.$emoji[rocket].$emoji[alien])"
# local prompt_based_on_last_command="%(?.$emoji[tropical_fish].$emoji[blowfish])"

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_UNTRACKED="$blue%%"
ZSH_THEME_GIT_PROMPT_MODIFIED="$red*"
ZSH_THEME_GIT_PROMPT_ADDED="$green+"
ZSH_THEME_GIT_PROMPT_STASHED="$blue$"
ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE="$green="
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE=">"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="<"
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="$red<>"

NEWLINE=$'\n'
# PROMPT_SYMBOL=" %#"
PROMPT_SYMBOL=""
PROMPT='$username_output$hostname_output:$current_dir_output%1(j. [$jobs_bg].)'
GIT_PROMPT='$(out=$(git_prompt_info)$(git_prompt_status)$(git_remote_status);if [[ -n $out ]]; then printf %s " $white($green$out$white)$reset";fi)'
PROMPT+="$GIT_PROMPT"
# PROMPT+=" $last_command_output%$reset "
PROMPT+="$NEWLINE $prompt_based_on_last_command >>$last_command_output$PROMPT_SYMBOL$reset "
RPROMPT=''
