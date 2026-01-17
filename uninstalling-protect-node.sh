#!/bin/bash

PANEL_PATH="/var/www/pterodactyl"
CONTROLLER="$PANEL_PATH/app/Http/Controllers/Admin/Nodes/NodeController.php"
ERROR_VIEW="$PANEL_PATH/resources/views/errors/403.blade.php"

echo "🧹 Uninstalling PROTECT NODE..."

# ================= RESTORE CONTROLLER =================
BACKUP_FILE=$(ls -t ${CONTROLLER}.bak_* 2>/dev/null | head -n 1)

if [ -z "$BACKUP_FILE" ]; then
  echo "❌ Backup NodeController tidak ditemukan!"
  echo "⚠️ Tidak bisa restore controller otomatis"
else
  mv "$BACKUP_FILE" "$CONTROLLER"
  echo "✅ NodeController berhasil direstore"
fi

# ================= REMOVE CUSTOM 403 VIEW =================
if [ -f "$ERROR_VIEW" ]; then
  rm -f "$ERROR_VIEW"
  echo "🗑️ Custom 403 view dihapus"
else
  echo "ℹ️ Custom 403 view tidak ditemukan"
fi

# ================= CLEAR CACHE =================
cd "$PANEL_PATH" || exit

php artisan view:clear
php artisan route:clear
php artisan config:clear

echo "✅ Cache Laravel dibersihkan"

# ================= PERMISSION =================
chmod 644 "$CONTROLLER"

echo "🎉 UNINSTALL PROTECT NODE SELESAI"
echo "🔓 Akses Nodes kembali NORMAL"
