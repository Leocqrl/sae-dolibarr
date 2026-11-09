#!/bin/bash
# backup.sh : sauvegarde la base de données et les documents
# Usage : ./backup.sh   (crée un dossier backup/<date>)

cd "$(dirname "$0")"

# Nom du dossier de sauvegarde, avec la date et l'heure
DOSSIER=backup/$(date +%Y%m%d_%H%M%S)
mkdir -p $DOSSIER

# 1) Export de toute la base dans un fichier SQL
docker exec dolibarr_db mariadb-dump -uroot -proot dolibarr > $DOSSIER/dolibarr.sql

# 2) Archive (tar) du volume des documents.
#    On lance un petit conteneur temporaire (alpine) qui voit le volume et le dossier de sauvegarde
docker run --rm -v dolibarr_documents:/data -v "$(pwd)/$DOSSIER":/backup alpine tar czf /backup/documents.tar.gz -C /data .

echo "Sauvegarde créée dans $DOSSIER"
