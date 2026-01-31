#!/bin/bash

# TrendX Database Backup Script
# This script creates MongoDB backups and optionally uploads to cloud storage

# Configuration
BACKUP_DIR="${BACKUP_DIR:-./backups}"
DB_NAME="${DB_NAME:-trendx}"
MONGO_URI="${MONGO_URI:-mongodb://localhost:27017}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP"

# Retention (days)
RETENTION_DAYS=7

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}TrendX Database Backup Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Perform backup
echo -e "${YELLOW}Starting backup...${NC}"
echo "Database: $DB_NAME"
echo "Target: $BACKUP_PATH"
echo ""

if mongodump --uri="$MONGO_URI" --db="$DB_NAME" --out="$BACKUP_PATH" --gzip; then
    echo -e "${GREEN}✓ Backup completed successfully${NC}"
    
    # Get backup size
    BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
    echo "Backup size: $BACKUP_SIZE"
    
    # Compress backup
    echo -e "${YELLOW}Compressing backup...${NC}"
    cd "$BACKUP_DIR" || exit
    tar -czf "${DB_NAME}_${TIMESTAMP}.tar.gz" "$(basename "$BACKUP_PATH")"
    rm -rf "$BACKUP_PATH"
    
    COMPRESSED_SIZE=$(du -sh "${DB_NAME}_${TIMESTAMP}.tar.gz" | cut -f1)
    echo -e "${GREEN}✓ Compressed to: $COMPRESSED_SIZE${NC}"
    
    # Clean old backups
    echo -e "${YELLOW}Cleaning old backups (older than $RETENTION_DAYS days)...${NC}"
    find "$BACKUP_DIR" -name "${DB_NAME}_*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete
    
    REMAINING_BACKUPS=$(find "$BACKUP_DIR" -name "${DB_NAME}_*.tar.gz" -type f | wc -l)
    echo -e "${GREEN}✓ Remaining backups: $REMAINING_BACKUPS${NC}"
    
    # TODO: Upload to cloud storage (S3, Google Cloud Storage, etc.)
    # Example for AWS S3:
    # if [ -n "$S3_BUCKET" ]; then
    #     echo -e "${YELLOW}Uploading to S3...${NC}"
    #     aws s3 cp "${DB_NAME}_${TIMESTAMP}.tar.gz" "s3://$S3_BUCKET/backups/"
    #     echo -e "${GREEN}✓ Uploaded to S3${NC}"
    # fi
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Backup completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
else
    echo -e "${RED}✗ Backup failed!${NC}"
    exit 1
fi
