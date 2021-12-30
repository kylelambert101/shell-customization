# shell-customization

A small repo for storing my favorite shell customizations including shell functions, aliases, prompts, and themes.

## Installation

### Bash Functions

1. Clone the repo
1. Load `bash-functions/source-me.bash` from your `~/.bashrc`:

```bash
source <path-to-custom-functions-repo>/bash-functions/source-me.bash
```

### Custom Git Prompt

To use the custom git prompt defined in `prompts/git-prompt.sh`, copy that file into `~/.config/git/` and reload bash.

### Custom zsh theme

To use the klam_custom zsh theme,

1. Copy `oh-my-zsh/klam_custom.zsh-theme` into `~/.oh-my-zsh/custom/themes/`
1. Specify `ZSH_THEME="klam_custom"` in `~/.zshrc`

### Windows Terminal Configuration

To apply config for Windows Terminal, copy `windows-terminal/.inputrc` into `~/.inputrc`, replacing or appending whatever's there.
