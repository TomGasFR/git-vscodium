#!/usr/bin/env bash
# sl.sh - Animation de locomotive pour terminal.
set -eu

TOP="        ____"
BOILER="  _____/|____\\___"
WINDOWS=" |  _   _   _   |"
WHEELS="=O-(_)-(_)-(_)-O="
TRAIN_WIDTH=17

if [ ! -t 1 ]; then
  printf '%s\n%s\n%s\n%s\n' "$TOP" "$BOILER" "$WINDOWS" "$WHEELS"
  exit 0
fi

WIDTH="${COLUMNS:-$(tput cols 2>/dev/null || printf '80')}"
case "$WIDTH" in
  ''|*[!0-9]*) WIDTH=80 ;;
esac

MAX_OFFSET=$((WIDTH - TRAIN_WIDTH))
if [ "$MAX_OFFSET" -lt 0 ]; then
  MAX_OFFSET=0
fi

offset=0
first_frame=1
while [ "$offset" -le "$MAX_OFFSET" ]; do
  if [ "$first_frame" -eq 0 ]; then
    printf '\033[4A\r'
  fi
  printf '\r\033[2K%*s%s\n' "$offset" '' "$TOP"
  printf '\r\033[2K%*s%s\n' "$offset" '' "$BOILER"
  printf '\r\033[2K%*s%s\n' "$offset" '' "$WINDOWS"
  printf '\r\033[2K%*s%s\n' "$offset" '' "$WHEELS"
  sleep 0.05
  offset=$((offset + 1))
  first_frame=0
done
