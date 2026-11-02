#!/bin/bash
# restore.sh : repart de zéro et restaure une sauvegarde
# Usage : sudo ./restore.sh backup/<date>

cd "$(dirname "$0")"

# Si aucun dossier n'est donné, on affiche l'aide et on s'arrête
if [ -z "$1" ]; then
  echo "Usage : ./restore.sh backup/<date>"
  exit 1
fi

# 1) On réinstalle tout avec le script d'installation
./install.sh

# 2) On recharge le fichier SQL dans la base (il remplace les tables)
docker exec -i dolibarr_db mariadb -uroot -proot dolibarr < $1/dolibarr.sql

# 3) On remet les documents dans le volume
docker run --rm -v dolibarr_documents:/data -v "$(pwd)/$1":/backup alpine tar xzf /backup/documents.tar.gz -C /data

echo "Restauration terminée"
