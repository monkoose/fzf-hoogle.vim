#!/usr/bin/env bash

# json item from temporary file with help of fzf {n} ($3)
LINE="sed -n $(($3+1))p $1"
JQ="jq -r"

package="$($LINE | $JQ '.package.name // empty')"
if [[ -n "$package" ]]; then
  tput setaf 4
  echo "$package"
  tput sgr0
  tput setaf 2
  eval "$LINE | $JQ '.module.name // empty'"
  tput sgr0
  echo ''
fi
tput setaf 11
eval "$LINE | $JQ '.item'"
tput sgr0
echo ''
eval "$LINE | $JQ '.docs' | sed 's/<pre>/$(tput setaf 6)/g; s/<\/pre>/$(tput sgr0)/g; s/<[^>]*>//g; s/&amp;/\&/g; s/&gt;/>/g; s/&lt;/</g'"
