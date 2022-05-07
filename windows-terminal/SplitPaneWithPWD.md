# Preserving PWD when Splitting the Windows Terminal Pane

## Background

Splitting the terminal using `alt+shift+plus` or `alt+shift+minus` defaults to open the new shell at your home directory.

I prefer the VSCode integrated terminal behavior of opening new panes at the working directory of the active pane. Luckily, this can be configured pretty easily.

## Steps

1. Capture `$PWD` to the terminal as part of the prompt by adding the following line to `.bashrc` - it shouldn't affect any other `PROMPT_COMMAND` customizations.

```bash
# Capture PWD when rendering prompt
PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND; "}'printf "\e]9;9;%s\e\\" "`cygpath -w $PWD`"'
```

2. (Optional) Update Terminal keybindings to duplicate when splitting panes by opening Terminal's `settings.json` and pasting the following objects into the `actions` array:

```json
{
  "command": {
    "action": "splitPane",
    "split": "vertical",
    "splitMode": "duplicate"
  },
  "keys": "alt+shift+plus"
},
{
  "command": {
    "action": "splitPane",
    "split": "horizontal",
    "splitMode": "duplicate"
  },
  "keys": "alt+shift+minus"
}
```

3. Restart Terminal

## Resources

- [Microsoft Docs about this process](https://docs.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory)
- [PR with Git Bash instructions](https://github.com/MicrosoftDocs/terminal/pull/525)
