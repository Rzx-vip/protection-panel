#!/bin/bash

PANEL_PATH="/var/www/pterodactyl"

MIDDLEWARE="$PANEL_PATH/app/Http/Middleware/ProtectNode.php"
KERNEL="$PANEL_PATH/app/Http/Kernel.php"
ERROR_VIEW="$PANEL_PATH/resources/views/errors/403.blade.php"

echo "🧹 UNINSTALL PROTECT NODE (EMERGENCY MODE)"

# ================= REMOVE MIDDLEWARE FILE =================
if [ -f "$MIDDLEWARE" ]; then
  rm -f "$MIDDLEWARE"
  echo "✅ Middleware ProtectNode dihapus"
else
  echo "ℹ️ Middleware tidak ditemukan"
fi

# ================= UNREGISTER FROM KERNEL =================
if grep -q "ProtectNode::class" "$KERNEL"; then
  sed -i "/ProtectNode::class/d" "$KERNEL"
  echo "✅ Middleware dilepas dari Kernel.php"
else
  echo "ℹ️ Kernel sudah bersih"
fi

# ================= REMOVE CUSTOM 403 VIEW =================
if [ -f "$ERROR_VIEW" ]; then
  rm -f "$ERROR_VIEW"
  echo "✅ Custom 403 view dihapus"
else
  echo "ℹ️ 403 view tidak ditemukan"
fi

# ================= CLEAR ALL CACHE =================
cd "$PANEL_PATH" || exit
php artisan optimize:clear

echo "🎉 UNINSTALL SELESAI"
echo "🔓 PANEL KEMBALI NORMAL"
