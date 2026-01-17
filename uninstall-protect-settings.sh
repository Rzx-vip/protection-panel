#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
SETTINGS_DIR="$PANEL/app/Http/Controllers/Admin/Settings"
ERROR_VIEW="$PANEL/resources/views/errors/403.blade.php"

echo "🧹 UNINSTALL PROTECT SETTINGS (FULL CLEAN MODE)"

# ================= RESTORE BACKUPS =================
restore_latest () {
  FILE="$1"
  BACKUP=$(ls "$FILE".bak_* 2>/dev/null | tail -n 1)

  if [ -f "$BACKUP" ]; then
    mv "$BACKUP" "$FILE"
    echo "♻️ Restored: $(basename "$FILE")"
  else
    echo "⚠️ No backup found for $(basename "$FILE")"
  fi
}

restore_latest "$SETTINGS_DIR/IndexController.php"
restore_latest "$SETTINGS_DIR/MailController.php"
restore_latest "$SETTINGS_DIR/AdvancedController.php"

# ================= REMOVE CUSTOM 403 VIEW =================
if [ -f "$ERROR_VIEW" ]; then
  rm -f "$ERROR_VIEW"
  echo "🗑️ Removed custom 403 view"
fi

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear

echo "✅ UNINSTALL PROTECT SETTINGS SELESAI"
echo "🔓 SETTINGS SUDAH NORMAL"
echo "♻️ ID 1, 2, 3 SEMUA BISA BUKA SETTINGS"
