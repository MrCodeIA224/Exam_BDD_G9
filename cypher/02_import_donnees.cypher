// =========================================================
// 02_import_donnees.cypher
// Import des données depuis des fichiers CSV placés dans /import
// Format attendu : clients.csv, produits.csv, agents.csv, reclamations.csv
// =========================================================

// --- Clients ---
LOAD CSV WITH HEADERS FROM 'file:///clients.csv' AS row
MERGE (c:Client {id: row.id})
SET c.nom = row.nom,
    c.segment = row.segment,
    c.dateInscription = date(row.dateInscription);

// --- Produits ---
LOAD CSV WITH HEADERS FROM 'file:///produits.csv' AS row
MERGE (p:Produit {id: row.id})
SET p.nom = row.nom,
    p.categorieProduit = row.categorieProduit;

// --- Agents ---
LOAD CSV WITH HEADERS FROM 'file:///agents.csv' AS row
MERGE (a:Agent {id: row.id})
SET a.nom = row.nom,
    a.equipe = row.equipe,
    a.niveauExpertise = row.niveauExpertise;

// --- Catégories, canaux et causes (référentiels) ---
LOAD CSV WITH HEADERS FROM 'file:///categories.csv' AS row
MERGE (:Categorie {nom: row.nom});

LOAD CSV WITH HEADERS FROM 'file:///canaux.csv' AS row
MERGE (:Canal {nom: row.nom});

LOAD CSV WITH HEADERS FROM 'file:///causes.csv' AS row
MERGE (:CauseRacine {nom: row.nom, description: row.description});

// --- Réclamations + relations ---
LOAD CSV WITH HEADERS FROM 'file:///reclamations.csv' AS row
MERGE (r:Reclamation {id: row.id})
SET r.dateCreation = date(row.dateCreation),
    r.description = row.description,
    r.statut = row.statut,
    r.priorite = row.priorite,
    r.sentimentScore = toFloat(row.sentimentScore),
    r.tempsResolutionHeures = toFloat(row.tempsResolutionHeures)

WITH r, row
MATCH (c:Client {id: row.clientId})
MATCH (p:Produit {id: row.produitId})
MATCH (a:Agent {id: row.agentId})
MATCH (cat:Categorie {nom: row.categorie})
MATCH (ch:Canal {nom: row.canal})
MATCH (cs:CauseRacine {nom: row.cause})

MERGE (c)-[:A_SOUMIS {date: date(row.dateCreation)}]->(r)
MERGE (r)-[:CONCERNE]->(p)
MERGE (r)-[:TRAITEE_PAR {dateAffectation: date(row.dateCreation)}]->(a)
MERGE (r)-[:APPARTIENT_A]->(cat)
MERGE (r)-[:VIA_CANAL]->(ch)
MERGE (r)-[:A_POUR_CAUSE {confiance: toFloat(row.confianceCause)}]->(cs);
