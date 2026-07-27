// =========================================================
// 03_requetes_critiques.cypher
// Requêtes d'analyse — Partie 4 du rapport
// =========================================================

// --- 1. Top 5 des causes racines par volume de réclamations ---
MATCH (r:Reclamation)-[:A_POUR_CAUSE]->(cause:CauseRacine)
RETURN cause.nom AS cause, count(r) AS nbReclamations
ORDER BY nbReclamations DESC
LIMIT 5;

// --- 2. Clients récidivistes (3 réclamations ou plus) ---
MATCH (c:Client)-[:A_SOUMIS]->(r:Reclamation)
WITH c, count(r) AS nb
WHERE nb >= 3
RETURN c.nom AS client, nb AS nbReclamations
ORDER BY nbReclamations DESC;

// --- 3. Réclamations critiques non résolues depuis plus de 48h, groupées par cause ---
MATCH (r:Reclamation)-[:A_POUR_CAUSE]->(cause:CauseRacine)
WHERE r.statut <> 'resolue'
  AND r.priorite = 'critique'
  AND duration.between(r.dateCreation, date()).hours > 48
RETURN cause.nom AS cause, count(r) AS nbEnRetard
ORDER BY nbEnRetard DESC;

// --- 4. Charge de travail par agent/équipe ---
MATCH (r:Reclamation)-[:TRAITEE_PAR]->(a:Agent)
RETURN a.equipe AS equipe, a.nom AS agent, count(r) AS nbTraitees
ORDER BY nbTraitees DESC;

// --- 5. Produits générant le plus de réclamations d'une catégorie donnée ---
MATCH (r:Reclamation)-[:CONCERNE]->(p:Produit),
      (r)-[:APPARTIENT_A]->(cat:Categorie {nom: 'Facturation'})
RETURN p.nom AS produit, count(r) AS nbReclamations
ORDER BY nbReclamations DESC
LIMIT 10;

// --- 6. Détection de réclamations similaires (nécessite la relation SIMILAIRE_A pré-calculée) ---
MATCH (r1:Reclamation)-[s:SIMILAIRE_A]->(r2:Reclamation)
WHERE s.score > 0.85
RETURN r1.id AS reclamation1, r2.id AS reclamation2, s.score AS similarite
ORDER BY similarite DESC
LIMIT 20;

// --- 7. Score de sentiment moyen par canal (identifier les canaux les plus "irritants") ---
MATCH (r:Reclamation)-[:VIA_CANAL]->(ch:Canal)
RETURN ch.nom AS canal, avg(r.sentimentScore) AS sentimentMoyen, count(r) AS volume
ORDER BY sentimentMoyen ASC;
