#!/usr/bin/env bash
# backup.sh - Sauvegarde FICTIVE d'InfraLab.
# Crée seulement un petit fichier texte dans le dossier local « backups/ ».
# Ne copie rien d'existant, ne supprime rien, ne se connecte à rien.
# Usage : bash scripts/backup.sh
set -eu

RETENTION_DAYS=7
BACKUP_DIR="backups"

HORODATAGE="$(date +%Y%m%d-%H%M%S)"
FICHIER="$BACKUP_DIR/infralab-$HORODATAGE.txt"

mkdir -p "$BACKUP_DIR"
{
  echo "Sauvegarde fictive InfraLab"
  echo "Date : $HORODATAGE"
  echo "Contenu : aucun (exercice de formation)"
} > "$FICHIER"

tar -xzf $FICHIER.tar.gz $FICHIER 2>/dev/null

echo "Sauvegarde créée : $FICHIER"
echo "Rétention configurée : $RETENTION_DAYS jours (aucune purge dans cet exercice)"

exit 0
