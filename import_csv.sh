#!/bin/bash
set -euo pipefail
CSV="${1:-data/tiers.csv}"
DB=dolibarrdebian
q() { printf "%s" "$1" | sed "s/'/''/g"; }
tail -n +2 "$CSV" | tr -d '\r' | while IFS=';' read -r nom cc cf adr cp ville pays tel mail client four; do
  [ -z "$nom" ] && continue
  printf "INSERT INTO llx_societe (nom,entity,datec,status,client,fournisseur,code_client,code_fournisseur,address,zip,town,fk_pays,phone,email,import_key) SELECT '%s',1,NOW(),1,%s,%s,NULLIF('%s',''),NULLIF('%s',''),'%s','%s','%s',(SELECT rowid FROM llx_c_country WHERE code='%s' LIMIT 1),'%s','%s','sae51' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM llx_societe WHERE nom='%s' AND entity=1);\n" "$(q "$nom")" "${client:-0}" "${four:-0}" "$(q "$cc")" "$(q "$cf")" "$(q "$adr")" "$(q "$cp")" "$(q "$ville")" "$(q "$pays")" "$(q "$tel")" "$(q "$mail")" "$(q "$nom")"
done | sudo mariadb "$DB"
echo "Import terminé : $(sudo mariadb "$DB" -N -e 'SELECT COUNT(*) FROM llx_societe;') tiers en base."
