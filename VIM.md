# Motion

`0` `$` - jump to first / last character of the line  
`^` `g_` - jump to first / last printable character of the line

`w` - go forward one word  
`W` - go forward one WORD  
`e` - go forward to the end of word  
`E` - go forward to the end of WORD

`b` - go backward one word  
`B` - go backward one WORD  
`ge` - go backward to the end of previous word  
`gE` - go backward to the end of previous WORD

`gj` `gk` - go upwards / downwards through the visual lines (used in wrapped lines)  
`g0` `g$` - go to beginning / end of the current visual line (used in wrapped lines)

`f<char>` - search and jump ON particular character in current line  
`F<char>` - go backward  
`t<char>` - search and jump BEFORE particular character in current line  
`T<char>` - go backward  
`;` - repeat the search and jump motion  
`,` - repeat the search and jump motion, but in the opposite direction

`%` - jump back and forth to the matching bracket, can find forward for the nearest bracket in current line  
`{` `}` - jump to the previous / next paragraph (empty line)  
`(` `)` - jump to the previous / next sentence (end with . ! ? eol)  
`[{` - jump backward to the beginning of current code block, "{"  
`]}` - jump forward to the ending of current code block, "}"  
`[(` - jump backward to previous "(" in current code block  
`])` - jump forward to next ")" in current code block  
`[[` - jump backward to the previous code section start  
`]]` - jump forward to the next code section start

`-` - move up one line and position cursor at first non-blank char  
`+` - move down one line and position cursor at first non-blank char

`g;` - jump to the older position in change list  
`g,` - jump to the newer position in change list 

`H` `L` `M` - move the cursor to the top / bottom / middle of the viewport

`zz` `zt` `zb` - move the line under the cursor to the top / middle / bottom of the viewport

`:<num>` - jump to specific line

`*` - search forward for the word cursor is currently on  
`#` - search backward for the word cursor is currently on

`Ctrl-o` - go backwards in the jump list  
`Ctrl-i` - go forwards in the jump list

`Ctrl-^` / `Ctrl-6` - alternate file

`Ctrl-e` - Scroll down one line  
`Ctrl-y` - Scroll up one line  
`Ctrl-d` - Scroll down half a page  
`Ctrl-u` - Scroll up half a page  
`Ctrl-f` - Scroll down full page  
`Ctrl-b` - Scroll up full page

## mark

`m<lowercase-letter>` - mark position under cursor with the lowercase letter (scope is current buffer)  
`'<lowercase-letter>` - jump to the mark with the lowercase letter  
`m<upper-letter>` - mark position under cursor with the upper letter (scope is current vim session)  
`'<upper-letter>` - jump to the mark with the upper letter, even the mark is at a different buffer

# Insert

`I` - insert from the beginning of current line  
`A` - append at the end of current line

`gu`{motion} - convert text covered by motion to lowercase  
`guu` `gugu` - convert current line to lowercase  
{VISUAL}`u` - convert selection to lowercase

`~` - toggle between upper and lower case  
`g~`{motion} - toggle text covered by motion between upper and lower case  
`g~~` - toggle current line between upper and lower case  
`gU`{motion} - convert text covered by motion to uppercase  
`gUU` `gUgU` - convert current line to uppercase  
{VISUAL}`U` - convert selection to uppercase

`cc` / `S` - delete [count] lines and start insert mode with proper indentation if `autoindent` is on

{INSERT}`Ctrl-w` - delete the previous word  
{INSERT}`Ctrl-u` - delete to the beginning of current line

{INSERT}`Ctrl-t` - increase indent of current line  
{INSERT}`Ctrl-d` - decrease indent of current line

{INSERT}`Ctrl-x Ctrl-l` - complete current line by searching backwards for lines starting with same text  
{INSERT}`Ctrl-x Ctrl-f` - complete the file name

# Visual

`o` - switch selection direction

`gv` - go back to the text you previously selected and reselect

`vi<surround>` - select within the surrounding (quotes, brackets ...)  
`va<surround>` - select within and including the surrounding  
`vib` - select within ()  
`viB` - select within {}

# Change

`S` `cc` - delete current line and start insert

`r` - replace character under cursor
`R` - enter REPLACE mode

`Ctrl-a` - increment the first number or alphabetic character at or after the cursor  
`Ctrl-x` - decrement the first number or alphabetic character at or after the cursor  
{VISUAL}`g Ctrl-a` - increment the first number or alphabetic character in highlighted lines

`=` - auto indent current line  
{VISUAL}`=` - auto indent selection  
`=ap` - auto indent current paragraph

`gq`{motion} - format the long lines covered by motion into multiple shorter lines  
`gqq` - format the current long line into multiple shorter lines

`J` - join the next line to the end of current line (put a space in between)  
`gJ` - join the next line to the end of current line (without a space in between)

`g&` - repeat last ":s" substitute action on all lines

# Delete

`D` - Delete from cursor to eol  
`dt<char>` - delete till the character  
`dap` - delete around current paragraph

# Repeat

`.` - repeat the last command

# Fold

`za` - toggle the fold on the section under cursor  
`zA` - toggle the fold on the section under cursor recursively

`zc` - close all folds under cursor  
`zC` - close all folds under cursor recursively  
`zo` - open all folds under cursor  
`zO` - open all folds under cursor recursively

`zM` - close all folds  
`zR` - open all folds

# Miscellaneous

`gf` - open file  
`gx` - open url  
`:X` - encrypt file

`g Ctrl-g` - display file statistic info

`q:` / `: Ctrl-f` - show all previous commands in a buffer

`ZZ` - save and quit  
`ZQ` - quit without saving

`:tabnew` - new tab  
`:tabclose` - close tab  
`gt` - Go to next tab  
`gT` - Go to prev tab  
`<num>gt` - Go to specific tab

`Ctrl-z` - put vim in background without quitting, and restore with `fg` command in terminal

# Cmdline

`:g/<pattern>/<cmd>` - execute command on the lines that match the pattern

`:find<filename>` - find for files under cwd, you could use *, e.g. `:find *.md` search for filenames start or end with ".md"

`:ls` - list all the buffer  
`:b<bufname>` - jump to specific buffer, can only type substring instead of the full name

`:mksession <filename>` - save current vim session as "filename" file  
`source <filename>` - restore the saved session

# Neovim

`gcc` - toggle comment on current line  
`gc`{motion} - toggle comment on lines covered by motion  
{VISUAL}`gc` - toggle comment on selection

`grr` - list all references to the symbol under cursor in quickfix window

# Reference

:help motion.txt

https://cheatsheets.zip/vim

https://thevaluable.dev/vim-commands-beginner/  
https://thevaluable.dev/vim-intermediate/  
https://thevaluable.dev/vim-advanced/  
https://thevaluable.dev/vim-adept/  
https://thevaluable.dev/vim-veteran/  
https://thevaluable.dev/vim-expert/  
https://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim  
https://stackoverflow.com/questions/8750275/vim-super-fast-navigation
