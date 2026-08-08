// =========================================================
// 01_schema_contraintes.cypher
// Contraintes d'unicité et index — à exécuter en premier
// Compatible Neo4j Community Edition
// =========================================================

// --- Contraintes d'unicité (identifiants métier) ---
// Disponibles en Community Edition
CREATE CONSTRAINT client_id IF NOT EXISTS
FOR (c:Client) REQUIRE c.id IS UNIQUE;

CREATE CONSTRAINT reclamation_id IF NOT EXISTS
FOR (r:Reclamation) REQUIRE r.id IS UNIQUE;

CREATE CONSTRAINT produit_id IF NOT EXISTS
FOR (p:Produit) REQUIRE p.id IS UNIQUE;

CREATE CONSTRAINT agent_id IF NOT EXISTS
FOR (a:Agent) REQUIRE a.id IS UNIQUE;

CREATE CONSTRAINT categorie_nom IF NOT EXISTS
FOR (cat:Categorie) REQUIRE cat.nom IS UNIQUE;

CREATE CONSTRAINT cause_nom IF NOT EXISTS
FOR (cs:CauseRacine) REQUIRE cs.nom IS UNIQUE;

CREATE CONSTRAINT canal_nom IF NOT EXISTS
FOR (ch:Canal) REQUIRE ch.nom IS UNIQUE;


// --- Index secondaires pour accélérer les requêtes d'analyse fréquentes ---
// Disponibles en Community Edition
CREATE INDEX reclamation_statut IF NOT EXISTS
FOR (r:Reclamation) ON (r.statut);

CREATE INDEX reclamation_priorite IF NOT EXISTS
FOR (r:Reclamation) ON (r.priorite);

CREATE INDEX reclamation_date IF NOT EXISTS
FOR (r:Reclamation) ON (r.dateCreation);

// Index full-text pour la recherche libre dans les descriptions (utile pour le module NLP)
CREATE FULLTEXT INDEX reclamation_description_fulltext IF NOT EXISTS
FOR (r:Reclamation) ON EACH [r.description];
