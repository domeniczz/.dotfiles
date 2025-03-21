#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Get definition of selected word and display as a notification
#
# Thanks @BreadOnPenguins
# ------------------------------------------------------------------------------

word=$(wl-paste --primary)

query=$(curl -s "https://api.dictionaryapi.dev/api/v2/entries/en_US/$word")

[[ -z "$query" ]] && notify-send -h string:bgcolor:#bf616a --expire-time=3000 "Invalid word." && exit 0

# Show only first 3 definitions
def=$(echo "$query" | jq -r '[.[].meanings[] | {pos: .partOfSpeech, def: .definitions[].definition}] | .[:3].[] | "\n\(.pos). \(.def)"')

# Requires a notification daemon to be installed
notify-send --expire-time=60000 "$word" "$def"

### MORE OPTIONS :)

# Show first definition for each part of speech (thanks @morgengabe1 on youtube)
# def=$(echo "$query" | jq -r '.[0].meanings[] | "\(.partOfSpeech): \(.definitions[0].definition)\n"')

# Show all definitions
# def=$(echo "$query" | jq -r '.[].meanings[] | "\n\(.partOfSpeech). \(.definitions[].definition)"')

# Regex + grep for just definition, if anyone prefers that to jq
# def=$(grep -Po '"definition":"\K(.*?)(?=")' <<< "$query")

# bold=$(tput bold) # Print text bold with echo, for visual clarity
# normal=$(tput sgr0) # Reset text to normal
# echo "${bold}Definition of $word"
# echo "${normal}$def"
