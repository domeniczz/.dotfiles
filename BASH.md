# Command

`cd -` - cd to the previous directory you're in

`mkdir -p ./{dir1,dir2,dir3}` - make several directories at once
`mkdir -p ./dir_{rpm,txt,zip,pdf}` - make several directories at once

`cp file.txt{,.bak}` - create a copy of "file.txt" with name "file.txt.bak" 

`rm file[12]` - glob matching, command will delete both "file1" and "file2"

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

# Reference

https://www.gnu.org/software/bash/manual
