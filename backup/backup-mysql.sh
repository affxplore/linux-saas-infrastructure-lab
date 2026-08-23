#!/bin/bash
set -e

BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME="mysql-db"
DB_NAME="saasdb"
DB_USER="root"
DB_PASS="supersecretrootpass"
FILE_NAME="db_backup_${DATE}.sql"
docker exec ${CONTAINER_NAME} mysqldump -u${DB_USER} -p${DB_PASS} ${DB_NAME} > ${BACKUP_DIR}/${FILE_NAME}
tar -czf ${BACKUP_DIR}/${FILE_NAME}.tar.gz -C ${BACKUP_DIR} ${FILE_NAME}
rm ${BACKUP_DIR}/${FILE_NAME}
find ${BACKUP_DIR} -type f -name "*.tar.gz" -mtime +7 -delete
echo "[$(date)] Backup completed successfully: ${FILE_NAME}.tar.gz"
