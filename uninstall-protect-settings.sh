#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
SETTINGS="$PANEL/app/Http/Controllers/Admin/Settings"

echo "🧯 EMERGENCY UNINSTALL PROTECT SETTINGS"

restore () {
  FILE="$1"
  BACKUP=$(ls "$FILE".bak_* 2>/dev/null | sort | tail -n 1)

  if [ -f "$BACKUP" ]; then
    mv "$BACKUP" "$FILE"
    echo "♻️ Restored $(basename "$FILE")"
  else
    echo "❌ BACKUP TIDAK ADA: $(basename "$FILE")"
  fi
}

restore "$SETTINGS/IndexController.php"
restore "$SETTINGS/MailController.php"
restore "$SETTINGS/AdvancedController.php"

rm -f "$PANEL/resources/views/errors/403.blade.php"

cd "$PANEL"
php artisan optimize:clear

echo "✅ DONE — JIKA BACKUP ADA, SETTINGS SUDAH NORMALS"
