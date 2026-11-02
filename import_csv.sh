#!/bin/bash
# import_csv.sh : importe les tiers du fichier CSV dans Dolibarr
# Usage : ./import_csv.sh
#
# Principe : Dolibarr range ses tiers dans la table SQL "llx_societe".
# Pour chaque ligne du CSV, on fabrique une requête INSERT,
# puis on envoie toutes les requêtes à la base de données.

cd "$(dirname "$0")"

FICHIER=data/tiers.csv      # le fichier CSV à importer
SQL=/tmp/import.sql         # le fichier où on écrira les requêtes SQL

# On vide le fichier SQL (au cas où il existe déjà)
> $SQL

# 1) On lit le CSV en sautant la 1ère ligne (l'en-tête)
#    tail -n +2    : affiche à partir de la ligne 2
#    tr -d '\r'    : enlève les retours à la ligne Windows (invisibles)
#    while ... read : répète pour chaque ligne, en coupant sur ";"
#                     et en rangeant chaque morceau dans une variable
tail -n +2 $FICHIER | tr -d '\r' | while IFS=';' read nom adresse cp ville tel email client fournisseur
do
  # 2) On écrit une requête INSERT dans le fichier SQL (>> = ajouter à la fin)
  echo "INSERT INTO llx_societe (nom, address, zip, town, phone, email, client, fournisseur, entity, status, datec) VALUES ('$nom', '$adresse', '$cp', '$ville', '$tel', '$email', $client, $fournisseur, 1, 1, NOW());" >> $SQL
done

# 3) On envoie le fichier SQL à la base de données dans le conteneur
docker exec -i dolibarr_db mariadb -uroot -proot dolibarr < $SQL

echo "Import terminé : $(wc -l < $SQL) tiers importés"
