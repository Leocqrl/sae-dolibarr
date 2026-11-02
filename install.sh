#!/bin/bash
# install.sh : installe Docker (si besoin), puis Dolibarr + MariaDB
# Usage : sudo ./install.sh

# Si une commande échoue, le script s'arrête
set -e

# On se place dans le dossier du script pour trouver docker-compose.yml
cd "$(dirname "$0")"

# Si la commande docker n'existe pas, on installe Docker avec le script officiel
if ! command -v docker > /dev/null; then
  echo "Installation de Docker..."
  apt-get update
  apt-get install -y curl
  curl -fsSL https://get.docker.com | sh
fi

# Télécharge les images et lance les 2 conteneurs en arrière-plan (-d)
docker compose up -d

# Attend que MariaDB réponde (on réessaie toutes les 3 secondes)
echo "Attente de MariaDB..."
until docker exec dolibarr_db mariadb -uroot -proot -e "SELECT 1" > /dev/null 2>&1; do
  sleep 3
done

# Attend que Dolibarr ait créé ses tables (llx_societe = table des tiers)
echo "Attente de l'installation de Dolibarr (1 à 2 minutes)..."
until docker exec dolibarr_db mariadb -uroot -proot dolibarr -e "SELECT 1 FROM llx_societe LIMIT 1" > /dev/null 2>&1; do
  sleep 5
done

echo "Terminé : Dolibarr est disponible sur http://localhost:8080 (admin / admin)"
