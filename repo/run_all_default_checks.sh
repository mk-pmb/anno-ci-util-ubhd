#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function run_all_default_checks_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local ACIU_REPO="$(readlink -m -- "$BASH_SOURCE"/../..)"
  local ACIU_NAME='s~",$~~; s~^\{? *"name": *"~~p'
  ACIU_NAME="$(sed -nre "$ACIU_NAME" -- "$ACIU_REPO"/package.json)"

  local TODO=(
    linters/vocab-lint/vocab-lint.sh
    )

  local ITEM=
  for ITEM in "${TODO[@]}"; do
    echo D: "$ACIU_NAME: Run check $ITEM:"
    "$ACIU_REPO/$ITEM" || return $?$(
      echo E: "$ACIU_NAME: Check failed (rv=$?): $ITEM" >&2)
  done
  echo D: "$ACIU_NAME: All default checks passed."
}


run_all_default_checks_cli_init "$@"; exit $?
