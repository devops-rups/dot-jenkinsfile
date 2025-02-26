#!/bin/bash

# Variables
BASE_DIRECTORY="/var/www/backups"
SOURCE_DIRECTORY="/var/www/development/shcbackend/main-service"
DATE_TIME=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIRECTORY="${BASE_DIRECTORY}/main-service_backup_${DATE_TIME}"

# Backup Process
echo "📂 Creating backup directory: ${BACKUP_DIRECTORY}"
sudo mkdir -p "${BACKUP_DIRECTORY}"
sudo rsync -av "${SOURCE_DIRECTORY}/" "${BACKUP_DIRECTORY}/"

echo "✅ Backup completed successfully: ${BACKUP_DIRECTORY}"

