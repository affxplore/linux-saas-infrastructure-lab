#!/bin/bash
set -e

CONTAINER_NAME="mysql-db"
DB_NAME="saasdb"
DB_USER="root"
DB_PASS="supersecretrootpass"

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./restore-mysql.sh /path/to/backup_file.tar.gz"
    exit 1
fi

TEMP_DIR=$(mktemp -d)
tar -xzf ${BACKUP_FILE} -C ${TEMP_DIR}
SQL_FILE=$(ls ${TEMP_DIR}/*.sql)

# Import kembali file SQL ke dalam container MySQL
docker exec -i ${CONTAINER_NAME} mysql -u${DB_USER} -p${DB_PASS} ${DB_NAME} < ${SQL_FILE}

rm -rf ${TEMP_DIR}
echo "[$(date)] Database restored successfully from ${BACKUP_FILE}"
