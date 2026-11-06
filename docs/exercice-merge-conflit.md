# Exercice : résoudre un conflit de fusion sur GitHub

## Objectif

Fusionner deux branches qui modifient la même ligne, puis résoudre le conflit
depuis l'interface GitHub.

## Préparation

Les branches `exo/merge-conflit-2-a` et `exo/merge-conflit-2-b` partent toutes
les deux de `dev` et modifient différemment la première ligne de
`exercises/merge-conflict-2/message.txt`. La deuxième ligne doit être conservée.

## Déroulement

1. Créer une pull request de `exo/merge-conflit-2-a` vers `dev`, puis la fusionner.
2. Créer la pull request de `exo/merge-conflit-2-b` vers `dev`. GitHub signale
   alors le conflit sur `message.txt`.
3. Choisir **Resolve conflicts** dans GitHub et remplacer les marqueurs de
   conflit par une formulation convenue, par exemple :

   ```text
   Accueil : Bienvenue dans l'equipe InfraLab !
   Equipe : Infrastructure.
   ```

4. Marquer le conflit comme résolu, valider le commit de résolution, puis
   fusionner la deuxième pull request.

Ne pas fusionner la branche B avant la branche A : le conflit apparaît lorsque
les modifications concurrentes doivent être intégrées à `dev`.
