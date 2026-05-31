#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function vocab_lint_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  # cd -- "$SELFPATH" || return $?

  local NAMESPACES=( $( cd -- "$SELFPATH" &&
    grep -hoPe '^\w+(?=:)' -- *.good.txt | sort -u ) )
  local RGX="${NAMESPACES[*]}"
  RGX='\b('"${RGX// /|}"'):\w+'
  exec < <(LANG=C git grep -PHone "$RGX" | grep -vPe '^linters/vocab-lint/')
  local LINT_SED= LEARN_SED=

  # Learn the "good" lists
  LEARN_SED='s!^[a-z]\S+$!/:&\$/d!p'
  LINT_SED+="$(echo; sed -nre "$LEARN_SED" -- "$SELFPATH"/*.good.txt)"

  # Learn the "prefer" lists
  LEARN_SED='
    s!\.prefer-! !
    s!\.txt:! !
    s~^\S+ (\S+) (\S+)~s=:\2\$=\&\\tPrefer \1:*!=~
    '
  LINT_SED+="$(echo; cd -- "$SELFPATH" && grep -HPe '^\w' \
    -- *.prefer-*.txt | sed -rf <(echo "$LEARN_SED"))"

  local COMPLAINTS='
    /\t/!s~$~\tNon-standard field!~
    '
  COMPLAINTS="$( sed -rf <(echo "$LINT_SED") | sed -rf <(echo "$COMPLAINTS") )"
  if [ -z "$COMPLAINTS" ]; then
    echo D: 'vocab lint had no complaints.'
    return 0
  fi

  echo "$COMPLAINTS" | nl -ba
  echo E: 'vocab lints had some complaints.' >&2
  return 2
}










vocab_lint_cli_init "$@"; exit $?
