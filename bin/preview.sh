#!/usr/bin/env bash

if [ ! -r "$1" ]; then
  echo "$(tput setaf 1)fzf-hoogle temporary file not found $(tput setaf 3)${1}$(tput sgr0)"
  exit 1
fi

# json item from temporary file with help of fzf {n} ($3)
LINE="sed -n $(($3+1))p $1"

eval "$LINE | jq -r '.package.name // empty' | sed 's/^/$(tput setaf 4)/; s/$/$(tput sgr0)/'"
eval "$LINE | jq -r '.module.name // empty' | sed 's/^/$(tput setaf 2)/; s/$/$(tput sgr0)/'"
eval "$LINE | jq -r '.item' | sed 's/^/$(tput setaf 11)/; s/$/$(tput sgr0)\n/' "
eval "$LINE | jq -r '.docs' | sed 's/<pre>/$(tput setaf 8)/g; s/<\/pre>/$(tput sgr0)/g; s/<[^>]*>//g; s/&amp;/\&/g; s/&gt;/>/g; s/&lt;/</g'"
