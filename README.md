# 📱 Plateforme Intelligente d'Analyse des Réclamations Clients (Télécom NoSQL)

Ce projet implémente une plateforme de centralisation et d'analyse des réclamations clients pour un opérateur télécom en utilisant la base de données orientée graphe **Neo4j**. 

L'objectif est d'interconnecter instantanément les clients, leurs plaintes, les canaux utilisés, les produits affectés et les agents du support afin de détecter les pannes réseaux et les pannes applicatives en temps réel [1.2, 2.2].

---

## ⚙️ Fonctionnement du Système

Contrairement aux bases relationnelles (SQL) qui ralentissent avec l'accumulation des données à cause des jointures coûteuses, notre système repose sur deux piliers de l'architecture Neo4j :

1. **Le Modèle de Graphe de Propriétés (Property Graph Model) :** Chaque entité (Client, Réclamation, Agent, Canal) est un nœud physique indépendant [1.1, 2.2]. Les interactions sont matérialisées par des relations directes (ex: `(:Client)-[:A_SOUMIS]->(:Reclamation)`) [2.2].
2. **L'Adjacence sans Index (Index-Free Adjacency) :** Chaque nœud détient directement les adresses mémoires des éléments auxquels il est connecté [1.1, 1.2]. Pour naviguer d'un client à sa réclamation, le système suit un pointeur physique en temps constant \(O(1)\), peu importe que la base contienne 1 000 ou 100 millions de lignes [1.1, 1.2].

---

## 📂 Structure du Projet

Assurez-vous que votre répertoire local respecte scrupuleusement cette arborescence :

```text
EXAM_BDD_G9/
│
├── docker-compose.yml       # Configuration du conteneur Neo4j
├── README.md                # Documentation de l'application
│
└── neo4j/                   # Dossier centralisé Neo4j
    ├── import/              # Contient vos scripts d'initialisation (ex: init.cypher)
    ├── data/                # [Généré par Docker] Fichiers binaires neostore de la base
    └── logs/                # [Généré par Docker] Journaux d'erreurs du serveur
├── cypher/
│   ├── 01_schema_contraintes.cypher   # Contraintes d'unicité, existence et index
│   ├── 02_import_donnees.cypher       # Import des données via LOAD CSV
│   └── 03_requetes_critiques.cypher   # Requêtes d'analyse (Partie 4 du rapport)
├── app/
│   └── connexion.py              # Client Python (driver officiel neo4j)
├── requirements.txt              # exigences python
```

---

## 🚀 Guide de Déploiement et Commandes de A à Z

Suivez ces étapes dans l'ordre pour lancer la plateforme sur votre machine.

### Étape 1 : Récupérer le projet (Pour l'équipe)
Si vous travaillez avec Git, ouvrez votre terminal dans votre dossier de travail et récupérez les fichiers :
```bash
git pull origin main
```

### Étape 2 : Préparer le script d'initialisation
Placez le fichier `init.cypher` que vous avez créé à l'intérieur du dossier `neo4j/import/`.

### Étape 3 : Démarrer le serveur Neo4j avec Docker
À la racine de votre projet (là où se trouve le fichier `docker-compose.yml`), exécutez la commande suivante pour construire et lancer la base de données en arrière-plan :
```bash
docker compose up -d
```
*Note : Lors de ce premier lancement, Docker va créer automatiquement les répertoires `neo4j/data/` et `neo4j/logs/`.*
  
### Étape 4 : Vérifier l'état du conteneur
Pour vous assurer que le serveur a démarré correctement et qu'il n'y a pas d'erreur de mémoire :
```bash
docker compose ps
```

### Étape 5 : Initialiser les données de la base
1. Ouvrez votre navigateur web et accédez à l'interface graphique officielle de Neo4j : **`http://localhost:7474`**
2. Connectez-vous à la base avec les identifiants définis dans le fichier de configuration :
   * **Utilisateur :** `neo4j`
   * **Mot de passe :** `M1_IA_BDD_G9`
3. Ouvrez le fichier `init.cypher`, copiez l'intégralité de son contenu, collez-le dans la console Neo4j (la barre de saisie tout en haut de l'écran) et cliquez sur le bouton bleu **Play/Exécuter**. Votre graphe est maintenant entièrement généré [4.2].

### AUTRES ETAPES AUSSI

1. **Initialiser le schéma** (contraintes + index) :
   Copier le contenu de `cypher/01_schema_contraintes.cypher` dans Neo4j Browser, ou :
   ```bash
   cat cypher/01_schema_contraintes.cypher | docker exec -i neo4j-reclamations cypher-shell -u neo4j -p reclamations_2026
   ```

2. **Importer les données** :
   Placer les fichiers CSV (`clients.csv`, `produits.csv`, `agents.csv`, `categories.csv`, `canaux.csv`, `causes.csv`, `reclamations.csv`) dans le dossier `./import` (monté automatiquement par docker-compose), puis exécuter :
   ```bash
   cat cypher/02_import_donnees.cypher | docker exec -i neo4j-reclamations cypher-shell -u neo4j -p reclamations_2026
   ```

3. **Exécuter les requêtes critiques** :
   Ouvrir `cypher/03_requetes_critiques.cypher` dans Neo4j Browser pour explorer les résultats, ou lancer le client Python :
   ```bash
   pip install -r requirements.txt
   python app/connexion.py
   ```

## Plugins activés

- **APOC** : procédures étendues (import avancé, manipulation de graphe.).
- **Graph Data Science (GDS)** : algorithmes de graphe (similarité, PageRank, détection de communautés) — utile pour enrichir la relation `SIMILAIRE_A` entre réclamations via des embeddings ou du clustering.

---

## 🛠️ Commandes Utiles de Gestion (Maintenance)

* **Voir les logs du serveur en temps réel :**
  ```bash
  docker compose logs -f neo4j_serveur
  ```
* **Arrêter temporairement la plateforme (sans perdre les données) :**
  ```bash
  docker compose stop
  ```
* **Redémarrer la plateforme :**
  ```bash
  docker compose start
  ```
* **Supprimer complètement le conteneur (les données restent préservées dans `./neo4j/data`) :**
  ```bash
  docker compose down
  ```

