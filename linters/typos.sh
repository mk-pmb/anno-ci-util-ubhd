#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function typos_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly

  local KNOWN_TYPOS=(
    '\bdcterns\b' 'dcterms'
    )

  local BAD= WHY= GREP= EXPLAIN='n'
  set -- "${KNOWN_TYPOS[@]}"
  while [ "$#" -ge 1 ]; do
    BAD="$1"; shift
    WHY="$1"; shift
    GREP+="$BAD|"
    EXPLAIN+=$'\ns|^'"$BAD"'$|& -> '"$WHY|"
  done
  GREP="${GREP%|}"

  git grep -PHone "$GREP" | sed -re 's~:[0-9]+:~&\ttypo:\n~' |
    sed -rf <(echo "$EXPLAIN") | sed -re 'N;s~\n~ ~' | grep . || return 0
  return 2
}










typos_cli_init "$@"; exit $?
