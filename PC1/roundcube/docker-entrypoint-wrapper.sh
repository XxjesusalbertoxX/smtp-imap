#!/bin/bash
# Wrapper del entrypoint oficial de Roundcube.
# Pre-crea el archivo sqlite.db como www-data para que initdb.sh
# lo encuentre ya existente y no lo cree como root.

set -e

DB_DIR="/var/roundcube/db"
DB_FILE="$DB_DIR/sqlite.db"

mkdir -p "$DB_DIR"
chown www-data:www-data "$DB_DIR"

# Pre-crear el archivo vacio con el owner correcto si no existe
if [ ! -f "$DB_FILE" ]; then
    touch "$DB_FILE"
    chown www-data:www-data "$DB_FILE"
    chmod 660 "$DB_FILE"
fi

# Corregir cualquier archivo .db con owner incorrecto (volumen reutilizado)
find "$DB_DIR" -name "*.db" ! -user www-data -exec chown www-data:www-data {} \;

# Pasar control al entrypoint oficial
exec /docker-entrypoint.sh "$@"
