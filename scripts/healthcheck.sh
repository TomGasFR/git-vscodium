#!/usr/bin/env bash
# healthcheck.sh - Contrôle de santé FICTIF d'InfraLab.
# Aucun accès réseau : on se contente de lire config/monitoring.yaml
# et d'afficher un résultat simulé pour chaque service.
# Usage : bash scripts/healthcheck.sh [fichier_de_config]
set -eu

CONFIG_FILE="${1:-config/monitoring.yaml}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Fichier de configuration introuvable : $CONFIG_FILE" >&2
  exit 1
fi

# Lit une valeur simple de la forme « clé: valeur » (et retire d'éventuels \r Windows).
lire() {
  grep -E "^$1:" "$CONFIG_FILE" | head -n 1 | cut -d: -f2- | tr -d ' \r'
}

echo "InfraLab - contrôle de santé (SIMULÉ)"
echo "Application : $(lire application) ($(lire environment))"
echo "Intervalle de contrôle : $(lire check_interval_seconds) s"

STATUT="OK"
# Associe chaque service à son port : « nom port »
while read -r nom port; do
  case "$port" in
    ''|*[!0-9]*) echo " - $nom : KO (port invalide)"; STATUT="KO" ;;
    *)           echo " - $nom (port $port) : OK" ;;
  esac
done < <(tr -d '\r' < "$CONFIG_FILE" | awk '/- name:/ {nom=$3} /port:/ {print nom, $2}')

echo "Statut global : $STATUT"
[ "$STATUT" = "OK" ]

exit 0
