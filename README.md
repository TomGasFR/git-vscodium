# InfraLab

InfraLab est une application interne **fictive** de supervision et d'exploitation.
Elle sert de support à la formation « Git et VS Codium » : tout y est inventé,
aucun script ne se connecte à un serveur, à un service ou à une base de données.

## Contexte métier

Une équipe d'exploitation (administrateurs, exploitants, DevOps) maintient chaque
jour de petits documents techniques :

- des procédures d'installatifggon et d'exploitation ;
- une fiche de gestion des incidents ;
- une configuration de supervision ;
- deux scripts Bash (contrôle de santé, sauvegarde) ;
- un fichier SQL de maintenance.

Tous ces fichiers évoluent, sont relus et partagés. Git permet de savoir
**qui a modifié quoi, quand et pourquoi**, et de revenir en arrière si besoin.

## Contenu du dépôt

| Dossier / fichier | Rôle |
|-------------------|------|
| `docs/` | Procédures : installation,le meilleurs exploitation, incidents |
| `config/` | Configuration de supervision et exemple de variables d'environnement |
| `scripts/` | Scripts Bash de démonstration et `nettoyage-pc-pret.ps1` (nettoyage local Windows) |
| `exercises/` | Fichiers de départ pour les exercices Git |
| `sql/` | Requêtes de maintenance à titre de démonstration (jamais exécutées) |
| `CHANGELOG.md` | Journal des modifications |

## Démarrage rapide

Depuis la racine du dépôt, dans un terminal Bash (Linux ou Git Bash sous Windows) :

```bash
bash scripts/healthcheck.sh
bash scripts/backup.sh
bash scripts/sl.sh
```

Pour préparer le retour d'un PC Windows prêté, vérifie d'abord les suppressions :

```powershell
.\scripts\nettoyage-pc-pret.ps1 -WhatIf
.\scripts\nettoyage-pc-pret.ps1
```

Le script supprime les profils locaux complets des navigateurs et vide
Téléchargements, Bureau, Documents, Images, Musique, Vidéos ainsi que certains
fichiers temporaires/récents du compte courant. Les mots de passe et favoris non
synchronisés sont perdus; ferme les navigateurs avant de l'exécuter. Le profil
Windows complet et le dépôt contenant le script sont conservés.

## Informations

- Responsable : à renseigner
- Version : 0.1.0
- Statut : application fictive, usage pédagogique uniquement
