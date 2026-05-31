#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
DC='dublin-core'
CHC="tmp.$DC.html"
URL="https://www.dublincore.org/specifications/$DC/dcmi-terms/"
URL="https://web.archive.org/web/20220404172535/$URL"
cache-file-wget "$CHC" "$URL"
exec <"$CHC"
export LANG=C

sed -nre 2p -- "$BASH_SOURCE" | tee -- \
  $DC-elem.good.txt \
  $DC-terms.all.txt \
  $DC-terms.good.txt \
  $DC-terms.prefer-dc.txt \
  >/dev/null

sed -nrf <(echo '
  /<td\b[^<>]*>Properties in the <code>/,/<\/tr>/p
  /<td\b[^<>]*>Vocabulary Encoding Schemes:/q
  ') | sed -nre 's~#http://purl\.org/([A-Za-z0-1./]+)~\n\1\n~p' | sort |
  tee  >(sed -nre 's~/elements/1\.1/~:~p' >>$DC-elem.good.txt) |
  sed -nre 's~/(terms)/~\1:~p' >>$DC-terms.all.txt

SED="$(sed -nre 's!^dc(:\S+)!;/\1\$/=!p' -- $DC-elem.good.txt | tr -d '\n')"
sed -nre "1p${SED//=/p}" -- $DC-terms.all.txt >$DC-terms.prefer-dc.txt
sed -re "${SED//=/d}" -- $DC-terms.all.txt >$DC-terms.good.txt
