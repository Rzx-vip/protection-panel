#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
TMP="/tmp/ptero-fix"

echo "🚑 EMERGENCY FIX PTERODACTYL CORE"

mkdir -p "$TMP"
cd "$TMP"

echo "⬇️ Download core Pterodactyl routes & controllers..."
curl -sSL https://github.com/pterodactyl/panel/archive/refs/heads/develop.zip -o panel.zip
unzip -q panel.zip

SRC="$TMP/panel-develop"

echo "🔄 RESTORE routes/admin.php"
cp "$SRC/routes/admin.php" "$PANEL/routes/admin.php"

echo "🔄 RESTORE Settings Controllers"
mkdir -p "$PANEL/app/Http/Controllers/Admin/Settings"
cp -r "$SRC/app/Http/Controllers/Admin/Settings/"* \
      "$PANEL/app/Http/Controllers/Admin/Settings/"

echo "🔄 RESTORE Kernel.php"
cp "$SRC/app/Http/Kernel.php" "$PANEL/app/Http/Kernel.php"

echo "🧹 REMOVE CUSTOM MIDDLEWARE"
rm -f "$PANEL/app/Http/Middleware/OwnerOnlySettings.php"

echo "🧹 REMOVE CUSTOM ERROR PAGES"
rm -f "$PANEL/resources/views/errors/403.blade.php"
rm -f "$PANEL/resources/views/errors/500.blade.php"

echo "🧼 CLEAR CACHE"
cd "$PANEL"
php artisan optimize:clear

echo "✅ EMERGENCY FIX SELESAI"
echo "🚀 PANEL HARUS SUDAH HIDUP"
