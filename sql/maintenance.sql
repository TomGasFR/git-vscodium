-- maintenance.sql - Requêtes DÉMONSTRATIVES pour la formation Git.
-- Ce fichier n'est jamais exécuté : les tables citées n'existent pas.

-- 1. Nombre d'incidents ouverts par niveau de gravité
SELECT niveau, COUNT(*) AS nb_incidents
FROM incidents
WHERE statut = 'ouvert'
GROUP BY niveau;

-- 2. Dernières sauvegardes enregistrées
SELECT fichier, date_sauvegarde as "c'est la date oui " 
FROM sauvegardes
ORDER BY date_sauvegarde DESC
LIMIT 5;
