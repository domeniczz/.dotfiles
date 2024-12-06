#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export PAGER="less -iR"

##### nnn file manager options #####

# optional args:
#  -a      auto NNN_FIFO
#  -A      no dir auto-enter during filter
#  -b key  open bookmark key (trumps -s/S)
#  -B      use bsdtar for archives
#  -c      cli-only NNN_OPENER (trumps -e)
#  -C      8-color scheme
#  -d      detail mode
#  -D      dirs in context color
#  -e      text in $VISUAL/$EDITOR/vi
#  -E      internal edits in EDITOR
#  -f      use readline history file
#  -F val  fifo mode [0:preview 1:explore]
#  -g      regex filters
#  -H      show hidden files
#  -i      show current file info
#  -J      no auto-advance on selection
#  -K      detect key collision
#  -l val  set scroll lines
#  -n      type-to-nav mode
#  -N      use native prompt
#  -o      open files only on Enter
#  -p file selection file [-:stdout]
#  -P key  run plugin key
#  -Q      no quit confirmation
#  -r      use advcpmv patched cp, mv
#  -R      no rollover at edges
#  -s name load session by name
#  -S      persistent session
#  -t secs timeout to lock
#  -T key  sort order [a/d/e/r/s/t/v]
#  -u      use selection (no prompt)
#  -U      show user and group
#  -V      show version
#  -x      notis, selection sync, xterm title
#  -0      use null separator in picker mode
#  -h      show help
export NNN_OPTS="acEHRU"
# 1: trash-cli, 2: gio trash
export NNN_TRASH=2
# e.g. <Leader> + D to open Downloads directory, leader key is `
export NNN_BMS="D:$HOME/Downloads/;r:$HOME/Personal/Repository;R:$HOME/Work/Repository"
# nnn plugins & custom commands
# https://github.com/jarun/nnn/tree/master/plugins
export NNN_PLUG_CMD_GIT='g:-!git diff;l:-!git log'
export NNN_PLUG_CMD_SUDOEDIT='e:-!sudo -E nvim "$nnn"*'
export NNN_PLUG_CMD_PAGE='p:-!less -iR "$nnn"*'
export NNN_PLUG_CMD_DUP='C:!cp -rv "$nnn" "$nnn".cp'
export NNN_PLUG_CMDS="$NNN_PLUG_CMD_GIT;$NNN_PLUG_CMD_SUDOEDIT;$NNN_PLUG_CMD_PAGE;$NNN_PLUG_CMD_DUP"
export NNN_PLUG_ENABLED='P:-preview-tui'
export NNN_PLUG="$NNN_PLUG_CMDS;$NNN_PLUG_ENABLED"

