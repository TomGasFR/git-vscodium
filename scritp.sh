#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
  printf 'Usage : %s\n' "$0" >&2
  exit 2
fi

if [[ ! -t 0 || ! -t 1 ]]; then
  printf 'Erreur : lancez ce script dans un terminal interactif.\n' >&2
  exit 1
fi

paragraph='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
paragraphs_per_page=14
total_pages=200

for ((page = 1; page <= total_pages; page++)); do
  printf '\n========== Page %d/%d ==========\n\n' "$page" "$total_pages"

  for ((line = 0; line < paragraphs_per_page; line++)); do
    printf '%s\n\n' "$paragraph"
  done

  if ((page < total_pages)); then
    printf '%s' '-- Appuyez sur Entrée pour continuer, ou tapez q puis Entrée pour quitter --'
    IFS= read -r answer </dev/tty || exit 0
    printf '\r\033[K'
    if [[ $answer == q || $answer == Q ]]; then
      exit 0
    fi
  fi
done
