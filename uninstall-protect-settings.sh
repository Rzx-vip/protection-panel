#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
TMP="/tmp/ptero-rescue"

echo "🚑 PTERODACTYL FULL CORE RESCUE (ANTI 500)"

rm -rf "$TMP"
mkdir -p "$TMP"
cd "$TMP"

echo "⬇️ Download Pterodactyl PANEL (STABLE RELEASE)"
curl -L https://github.com/pterodactyl/panel/archive/refs/tags/v1.11.7.zip -o panel.zip

unzip -q panel.zip

SRC="$TMP/panel-1.11.7"

echo "🔄 RESTORE ROUTES"
cp "$SRC/routes/admin.php" "$PANEL/routes/admin.php"
cp "$SRC/routes/web.php"   "$PANEL/routes/web.php"

echo "🔄 RESTORE ADMIN CONTROLLERS"
rsync -a \
  "$SRC/app/Http/Controllers/Admin/" \
  "$PANEL/app/Http/Controllers/Admin/"

echo "🔄 RESTORE HTTP KERNEL"
cp "$SRC/app/Http/Kernel.php" "$PANEL/app/Http/Kernel.php"

echo "🧹 REMOVE ALL CUSTOM PROTECT FILES"
rm -f "$PANEL/app/Http/Middleware/"*Protect*
rm -f "$PANEL/resources/views/errors/403.blade.php"
rm -f "$PANEL/resources/views/errors/500.blade.php"

echo "🧼 CLEAR LARAVEL CACHE"
cd "$PANEL"
php artisan optimize:clear
php artisan view:clear
php artisan route:clear
php artisan config:clear

echo "🔐 FIX PERMISSION"
chown -R www-data:www-data "$PANEL"
chmod -R 755 "$PANEL/storage" "$PANEL/bootstrap/cache"

echo "✅ RESCUE SELESAI"
echo "🚀 PANEL HARUS HIDUP SEKARANG"
