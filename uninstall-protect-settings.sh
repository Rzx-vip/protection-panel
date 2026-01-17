#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"

MIDDLEWARE="$PANEL/app/Http/Middleware/OwnerOnlySettings.php"
KERNEL="$PANEL/app/Http/Kernel.php"
ROUTES="$PANEL/routes/admin.php"

ERROR403="$PANEL/resources/views/errors/403.blade.php"
ERROR500="$PANEL/resources/views/errors/500.blade.php"

echo "🧹 UNINSTALL PROTECT SETTINGS (FULL CLEAN)"

# ================= REMOVE MIDDLEWARE FILE =================
if [ -f "$MIDDLEWARE" ]; then
  rm -f "$MIDDLEWARE"
  echo "✅ Middleware dihapus"
else
  echo "⚠️ Middleware tidak ditemukan"
fi

# ================= REMOVE KERNEL REGISTER =================
if grep -q "OwnerOnlySettings" "$KERNEL"; then
  sed -i "/OwnerOnlySettings::class/d" "$KERNEL"
  sed -i "/owner.settings/d" "$KERNEL"
  echo "✅ Kernel dibersihkan"
else
  echo "⚠️ Kernel sudah bersih"
fi

# ================= REMOVE ROUTE PROTECT =================
if grep -q "owner.settings" "$ROUTES"; then
  sed -i "/owner.settings/d" "$ROUTES"
  sed -i "/settings\\\\\\\\AdvancedController/d" "$ROUTES"
  sed -i "/settings\\\\\\\\MailController/d" "$ROUTES"
  sed -i "/settings', 'Settings/d" "$ROUTES"
  echo "✅ Route protect dihapus"
else
  echo "⚠️ Route protect tidak ditemukan"
fi

# ================= REMOVE ERROR HTML =================
if [ -f "$ERROR403" ]; then
  rm -f "$ERROR403"
  echo "✅ 403 custom dihapus"
fi

if [ -f "$ERROR500" ]; then
  rm -f "$ERROR500"
  echo "✅ 500 custom dihapus"
fi

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear

echo "🎉 UNINSTALL SELESAI"
echo "🔓 SETTINGS SUDAH NORMAL"
echo "🚀 PANEL BALIK DEFAULT"
