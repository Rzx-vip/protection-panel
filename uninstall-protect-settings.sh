#!/bin/bash
set -e

REMOTE="/var/www/pterodactyl/app/Http/Controllers/Admin/Settings/IndexController.php"

echo "🔥 UNINSTALL PROTECT SETTINGS (SAFE RESTORE)"

if ls ${REMOTE}.bak_* 1> /dev/null 2>&1; then
  LAST_BACKUP=$(ls -t ${REMOTE}.bak_* | head -n1)
  cp "$LAST_BACKUP" "$REMOTE"
  echo "♻ Restored from backup: $LAST_BACKUP"
else
  echo "⚠ Backup tidak ditemukan, restore dari repo resmi"

  curl -fsSL \
    https://raw.githubusercontent.com/pterodactyl/panel/develop/app/Http/Controllers/Admin/Settings/IndexController.php \
    -o "$REMOTE"
fi

php artisan optimize:clear
php artisan view:clear
php artisan route:clear
php artisan config:clear

echo "✅ SETTINGS NORMAL"
echo "🔓 500 ERROR HILANG"
