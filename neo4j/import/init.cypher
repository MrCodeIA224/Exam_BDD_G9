// =========================================================================
// ÉTAPE 1 : CRÉATION DES CONTRAINTES D'UNICITÉ (Sécurité et Indexation)
// =========================================================================
// Ces règles empêchent d'avoir deux clients ou réclamations avec le même identifiant.
CREATE CONSTRAINT unique_client_id IF NOT EXISTS FOR (c:Client) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT unique_rec_id IF NOT EXISTS FOR (r:Reclamation) REQUIRE r.id IS UNIQUE;
CREATE CONSTRAINT unique_agent_id IF NOT EXISTS FOR (a:Agent) REQUIRE a.id IS UNIQUE;
CREATE CONSTRAINT unique_produit_id IF NOT EXISTS FOR (p:Produit) REQUIRE p.id IS UNIQUE;

// =========================================================================
// ÉTAPE 2 : INITIALISATION DES NŒUDS DE CONFIGURATION FIXES (Canaux, Catégories)
// =========================================================================
// Utilisation de MERGE pour éviter les doublons si le script est rejoué.
MERGE (chan1:Canal {nom: "application_mobile"});
MERGE (chan2:Canal {nom: "chatbot"});
MERGE (chan3:Canal {nom: "agence_physique"});

MERGE (cat1:Categorie {nom: "facturation"});
MERGE (cat2:Categorie {nom: "panne_reseau"});
MERGE (cat3:Categorie {nom: "mobile_money"});

MERGE (cause1:CauseRacine {nom: "Bug_Mise_A_Jour_App", description: "Dysfonctionnement suite à la mise à jour v3.2"});
MERGE (cause2:CauseRacine {nom: "Surcharge_Antenne_Relais", description: "Saturation du trafic sur l'antenne locale"});

MERGE (kw1:MotCle {terme: "connexion"});
MERGE (kw2:MotCle {terme: "frais"});
MERGE (kw3:MotCle {terme: "echec"});

MERGE (prod1:Produit {id: "P-4G", nom: "Pass Internet Illimité", categorieProduit: "Data"});
MERGE (prod2:Produit {id: "P-CASH", nom: "Transfert National", categorieProduit: "Fintech"});

MERGE (ag1:Agent {id: "AG-01", nom: "Cheikh Tidiane", equipe: "Niveau_2_Technique", niveauExpertise: "Senior"});
MERGE (ag2:Agent {id: "AG-02", nom: "Fatou Kiné", equipe: "Niveau_1_Clientele", niveauExpertise: "Junior"});

// =========================================================================
// ÉTAPE 3 : INJECTION DES CLIENTS ET DES RÉCLAMATIONS (Simulations de crise)
// =========================================================================
// Client 1 (Profil VIP à fort risque de désabonnement selon l'IA)
CREATE (c1:Client {id: "CLI-001", nom: "Mamadou Diallo", segment: "VIP", dateInscription: date("2024-01-15")});

CREATE (r1:Reclamation {
  id: "REC2026-0001",
  dateCreation: datetime("2026-07-18T09:15:00"),
  dateResolution: null,
  description: "Impossible d'envoyer l'argent ce matin à la Médina, l'application plante et affiche un échec de connexion",
  statut: "en_cours",
  priorite: "haute",
  sentimentScore: -0.85,
  canalOrigine: "application_mobile",
  montantConcerne: 50000.0,
  estRecidive: true,
  nombreEscalades: 1
});

// Client 2 (Profil Standard)
CREATE (c2:Client {id: "CLI-002", nom: "Awa Diop", segment: "Standard", dateInscription: date("2025-06-20")});

CREATE (r2:Reclamation {
  id: "REC2026-0002",
  dateCreation: datetime("2026-07-18T09:42:00"),
  dateResolution: null,
  description: "Mon transfert d'argent a échoué mais mon solde a été débité. Bug de connexion de l'application",
  statut: "ouverte",
  priorite: "critique",
  sentimentScore: -0.92,
  canalOrigine: "application_mobile",
  montantConcerne: 15000.0,
  estRecidive: false,
  nombreEscalades: 0
});

// =========================================================================
// ÉTAPE 4 : TISSAGE DES RELATIONS (Recherche séquentielle par MATCH)
// =========================================================================
// Liaison de la Réclamation 1 aux entités correspondantes
MATCH (c:Client {id: "CLI-001"})
MATCH (r:Reclamation {id: "REC2026-0001"})
MATCH (p:Produit {id: "P-CASH"})
MATCH (can:Canal {nom: "application_mobile"})
MATCH (cat:Categorie {nom: "mobile_money"})
MATCH (a:Agent {id: "AG-01"})
MATCH (cause:CauseRacine {nom: "Bug_Mise_A_Jour_App"})
CREATE (c)-[:A_SOUMIS {date: date("2026-07-18")}]->(r)
CREATE (r)-[:CONCERNS]->(p)
CREATE (r)-[:VIA_CANAL]->(can)
CREATE (r)-[:APPARTIENT_A]->(cat)
CREATE (r)-[:TRAITEE_PAR {dateAffectation: datetime("2026-07-18T10:00:00")}]->(a)
CREATE (r)-[:A_POUR_CAUSE {confiance: 0.94}]->(cause);

// Liaison de la Réclamation 2 aux entités correspondantes
MATCH (c:Client {id: "CLI-002"})
MATCH (r:Reclamation {id: "REC2026-0002"})
MATCH (p:Produit {id: "P-CASH"})
MATCH (can:Canal {nom: "application_mobile"})
MATCH (cat:Categorie {nom: "mobile_money"})
MATCH (a:Agent {id: "AG-02"})
CREATE (c)-[:A_SOUMIS {date: date("2026-07-18")}]->(r)
CREATE (r)-[:CONCERNS]->(p)
CREATE (r)-[:VIA_CANAL]->(can)
CREATE (r)-[:APPARTIENT_A]->(cat)
CREATE (r)-[:TRAITEE_PAR {dateAffectation: datetime("2026-07-18T09:50:00")}]->(a);

// Liaison des mots-clés extraits par le traitement de texte (NLP)
MATCH (r1:Reclamation {id: "REC2026-0001"})
MATCH (r2:Reclamation {id: "REC2026-0002"})
MATCH (k_connex:MotCle {terme: "connexion"})
MATCH (k_echec:MotCle {terme: "echec"})
CREATE (r1)-[:CONTIENT_MOTCLE {poids: 0.88}]->(k_connex)
CREATE (r1)-[:CONTIENT_MOTCLE {poids: 0.75}]->(k_echec)
CREATE (r2)-[:CONTIENT_MOTCLE {poids: 0.95}]->(k_connex)
CREATE (r2)-[:CONTIENT_MOTCLE {poids: 0.91}]->(k_echec);

// =========================================================================
// ÉTAPE 5 : LIEN DE SIMILARITÉ SÉMANTIQUE (Calculé par le pipeline d'IA)
// =========================================================================
// L'IA relie les deux réclamations car elles expriment le même problème technique
MATCH (r1:Reclamation {id: "REC2026-0001"})
MATCH (r2:Reclamation {id: "REC2026-0002"})
CREATE (r1)-[:SIMILAR_A {score: 0.89}]->(r2);
