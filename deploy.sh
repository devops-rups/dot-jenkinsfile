#!/bin/bash

# Define variables
BASE_DIRECTORY="/var/www/backups"
SOURCE_DIRECTORY="/var/www/development/shcbackend/main-service"
ZIP_FILE="/var/www/releaseupload/main-service/WebApp.zip"
TEMP_DIR="/var/www/releaseupload/main-service/temp"
TARGET_DIR="/var/www/development/shcbackend/main-service"
SERVICE_NAME="main-service.service"
DATE_TIME=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIRECTORY="${BASE_DIRECTORY}/main-service_backup_${DATE_TIME}"
CONFIG_FILE_NAME="appsettings.production.json"

echo "=== Starting Deployment Process ==="

# Step 1: Backup the current deployment
echo "Creating backup: ${BACKUP_DIRECTORY}"
sudo mkdir -p "${BACKUP_DIRECTORY}"
sudo rsync -av "${SOURCE_DIRECTORY}/" "${BACKUP_DIRECTORY}"
echo "Backup completed!"

# Step 2: Stop the service
echo "Stopping service: ${SERVICE_NAME}"
sudo systemctl stop ${SERVICE_NAME} || exit 1

# Step 3: Prepare for deployment
echo "Clearing previous deployment..."
rm -rf "${TARGET_DIR}.bak"
mv "${TARGET_DIR}" "${TARGET_DIR}.bak"
mkdir -p "${TARGET_DIR}"

# Step 4: Extract new files
echo "Extracting new files..."
mkdir -p "${TEMP_DIR}"
unzip -q "${ZIP_FILE}" -d "${TEMP_DIR}" || exit 1

# Step 5: Update Configuration
CONFIG_FILE_PATH=$(find "${TEMP_DIR}" -type f -name "${CONFIG_FILE_NAME}")
if [ -n "${CONFIG_FILE_PATH}" ]; then
    CONFIG_DIR=$(dirname "${CONFIG_FILE_PATH}")
    cp "${CONFIG_FILE_PATH}" "${CONFIG_DIR}/appsettings.json"
    echo "Updated appsettings.json with ${CONFIG_FILE_PATH}"
else
    echo "Error: ${CONFIG_FILE_NAME} not found! Rolling back..."
    exit 1
fi

# Step 6: Move files to target directory
echo "Deploying new version..."
find "${TEMP_DIR}" -type f -exec mv {} "${TARGET_DIR}/" \;
find "${TEMP_DIR}" -type d -empty -delete
rm -rf "${TEMP_DIR}"

# Step 7: Restart the service
echo "Starting service: ${SERVICE_NAME}"
sudo systemctl start ${SERVICE_NAME} || exit 1

# Step 8: Cleanup old backup
echo "Cleaning up old backups..."
rm -rf "${TARGET_DIR}.bak"

echo "=== Deployment Successful! ==="

exit 0

