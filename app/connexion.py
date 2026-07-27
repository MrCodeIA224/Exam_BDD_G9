"""
connexion.py
Exemple de connexion applicative à Neo4j avec le driver officiel Python.
Utilisé pour exécuter les requêtes critiques depuis une application externe
(ex: dashboard de suivi des réclamations).
"""

from neo4j import GraphDatabase
import os

URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
USER = os.getenv("NEO4J_USER", "neo4j")
PASSWORD = os.getenv("NEO4J_PASSWORD", "reclamations_2026")


class ReclamationsClient:
    def __init__(self, uri: str, user: str, password: str):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self.driver.close()

    def top_causes(self, limit: int = 5):
        query = """
        MATCH (r:Reclamation)-[:A_POUR_CAUSE]->(cause:CauseRacine)
        RETURN cause.nom AS cause, count(r) AS nbReclamations
        ORDER BY nbReclamations DESC
        LIMIT $limit
        """
        with self.driver.session() as session:
            result = session.run(query, limit=limit)
            return [dict(record) for record in result]

    def clients_recidivistes(self, seuil: int = 3):
        query = """
        MATCH (c:Client)-[:A_SOUMIS]->(r:Reclamation)
        WITH c, count(r) AS nb
        WHERE nb >= $seuil
        RETURN c.nom AS client, nb AS nbReclamations
        ORDER BY nbReclamations DESC
        """
        with self.driver.session() as session:
            result = session.run(query, seuil=seuil)
            return [dict(record) for record in result]

    def charge_par_agent(self):
        query = """
        MATCH (r:Reclamation)-[:TRAITEE_PAR]->(a:Agent)
        RETURN a.equipe AS equipe, a.nom AS agent, count(r) AS nbTraitees
        ORDER BY nbTraitees DESC
        """
        with self.driver.session() as session:
            result = session.run(query)
            return [dict(record) for record in result]


if __name__ == "__main__":
    client = ReclamationsClient(URI, USER, PASSWORD)
    try:
        print("=== Top causes racines ===")
        for row in client.top_causes():
            print(row)

        print("\n=== Clients récidivistes ===")
        for row in client.clients_recidivistes():
            print(row)

        print("\n=== Charge par agent ===")
        for row in client.charge_par_agent():
            print(row)
    finally:
        client.close()
