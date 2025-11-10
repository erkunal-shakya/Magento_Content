#!/bin/bash

# === CONFIGURE THIS PATH ===
BACKUP_DIR="/home/kunalshakya/Downloads/Backups-20251104T091335Z-1-002/Backups/DB_Backups_oct32_2025/DB_Backups"

echo "Enter MySQL root password:"
read -s MYSQL_PASS

echo ""
echo "Starting database restore..."
echo ""

cd "$BACKUP_DIR" || { echo "Backup directory not found!"; exit 1; }

for f in *.sql; do
    DBNAME=$(basename "$f" .sql)
    
    echo "--------------------------------------------"
    echo "Creating database (if not exists): $DBNAME"
    echo "Importing backup file: $f"
    echo "--------------------------------------------"

    mysql -u root -p"$MYSQL_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$DBNAME\`;"
    mysql -u root -p"$MYSQL_PASS" "$DBNAME" < "$f"

    echo "✅ Successfully imported: $DBNAME"
    echo ""
done

echo "🎉 All databases restored successfully!"
