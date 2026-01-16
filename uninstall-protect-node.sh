#!/bin/bash

# ================= CONFIG =================
PANEL_PATH="/var/www/pterodactyl"
CONTROLLER="$PANEL_PATH/app/Http/Controllers/Admin/Nodes/NodeController.php"
VIEW_PATH="$PANEL_PATH/resources/views/errors"
VIEW_FILE="$VIEW_PATH/protect-node.blade.php"

echo "🧹 Uninstalling PROTECT NODE..."

# ================= RESTORE CONTROLLER =================
LATEST_BACKUP=$(ls -t "$CONTROLLER".bak_* 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ Backup controller tidak ditemukan"
else
  cp "$LATEST_BACKUP" "$CONTROLLER"
  echo "✅ Controller berhasil direstore dari:"
  echo "📦 $LATEST_BACKUP"
fi

# ================= REMOVE VIEW =================
if [ -f "$VIEW_FILE" ]; then
  rm -f "$VIEW_FILE"
  echo "🗑 View protect-node dihapus"
else
  echo "ℹ View protect-node tidak ditemukan"
fi

# ================= PERMISSION =================
chmod 644 "$CONTROLLER" 2>/dev/null
chmod -R 755 "$VIEW_PATH" 2>/dev/null

echo "✅ PROTECT NODE BERHASIL DIUNINSTALL"
echo "🔓 Semua admin bisa akses Nodes kembali"
