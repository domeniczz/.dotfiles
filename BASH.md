# Command

`cd -` - cd to the previous directory you're in

`mkdir -p ./{dir1,dir2,dir3}` - make several directories at once  
`mkdir -p ./dir_{rpm,txt,zip,pdf}` - make several directories at once

`cp file.txt{,.bak}` - create a copy of "file.txt" with name "file.txt.bak"

`rm file[12]` - glob matching, command will delete both "file1" and "file2"

## symbol

`>` - command > file, overwrite the file with output of the command
`>>` - command >> file, append the file with output of the command
`<` - command < file, pass the file content to stdin for the command

## grep

`grep '<string>' file` - grep specified string in the file  

`grep -A 3 '<string>' file` - grep specified string, print 3 lines after the match  
`grep -B 3 '<string>' file` - grep specified string, print 3 lines before the match  
`grep -C 3 '<string>' file` - grep specified string, print 3 lines before and after the match

`grep -Irl '<string>' dir` - list all files under the directory that contains specified string

## awk

`awk -F ; '{print $1}' file` - print the first column (separated with ;)  
`awk -F ; '/<string>/ {print $1}' file` - print the first column (separated with ;) that contains the specified string  
`awk -F ; '!/<string>/ {print $1}' file` - print the first column (separated with ;) that does not contain the specified string

# Special

`--` - end of command options, prevent values start with "-" be treated as options incorrectly

`!#` - represent the entire currently typed command  
`!#:<num>` - represent the specific part (index "num", starting at 0) of the currently typed command  
`!:<num>` - represent the specific part (index "num", starting at 0) of the previous command

`!!` - represent the previous command  
`!<string>` - represent the previous command starting with "string"  
`!$` - represent the last argument of the previous command as it's literally typed (shortcut of `!!:$`)  
`$_` - represent the last component of the previous command after expansions and substitutions

`^<s1>^<s2>` - search for "s1" in the previous command, and replace the first match with "s2"

# Hotkey

`Ctrl-l` - clear screen

`Ctrl-a` - go to front of the line
`Ctrl-e` - go to end of the line

`Ctrl-z` - put process in background, and use `fg` command to bring the process back to foreground

`Ctrl-x a` - expand alias inline

## bash only

`Ctrl-u` - delete everything before cursor in current line
`Ctrl-k` - delete everything after cursor in current line
`Ctrl-x Ctrl-e` - open current command in $EDITOR

# Reference

https://www.gnu.org/software/bash/manual
