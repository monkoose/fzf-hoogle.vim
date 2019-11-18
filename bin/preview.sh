#!/usr/bin/env bash

if [ ! -r "$1" ]; then
  echo "$(tput setaf 1)fzf-hoogle temporary file not found $(tput setaf 3)${1}$(tput sgr0)"
  exit 1
fi

dim=$(tput setaf 8)
blue=$(tput setaf 4)
green=$(tput setaf 2)
bold=$(tput setaf 11)
reset=$(tput sgr0)

LINE="sed -n $(($3+1))p $1"

PACKAGE="$LINE | jq -r '.package.name // empty'"
if [[ ! -z "$PACKAGE" ]]
then
  PACKAGE="$PACKAGE | sed 's/^/$blue/; s/$/$reset/'"
fi

MODULE="$LINE | jq -r '.module.name // empty'"
if [[ ! -z "$MODULE" ]]
then
  MODULE="$MODULE | sed 's/^/$green/; s/$/$reset/'"
fi

ITEM="$LINE | jq -r '.item' | sed 's/^/$bold/; s/$/$reset\n/' "

DOCS="$LINE | jq -r '.docs' | sed 's/<pre>/$dim/g; s/<\/pre>/$reset/g; s/<[^>]*>//g; s/&amp;/\&/g; s/&gt;/>/g; s/&lt;/</g'"

eval "$PACKAGE;$MODULE;$ITEM;$DOCS"
