#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
TMP="/tmp/ptero-rescue-112"

echo "🚑 PTERODACTYL 1.12.0 FULL RESCUE MODE"

rm -rf "$TMP"
mkdir -p "$TMP"
cd "$TMP"

echo "⬇️ Download PANEL v1.12.0 (OFFICIAL)"
curl -L https://github.com/pterodactyl/panel/archive/refs/tags/v1.12.0.zip -o panel.zip

unzip -q panel.zip

SRC="$TMP/panel-1.12.0"

echo "🔄 RESTORE ROUTES (ADMIN + CLIENT)"
rm -rf "$PANEL/routes"
cp -r "$SRC/routes" "$PANEL/routes"

echo "🔄 RESTORE ADMIN CONTROLLERS"
rm -rf "$PANEL/app/Http/Controllers/Admin"
cp -r "$SRC/app/Http/Controllers/Admin" "$PANEL/app/Http/Controllers/Admin"

echo "🔄 RESTORE BASE CONTROLLER"
cp "$SRC/app/Http/Controllers/Controller.php" \
   "$PANEL/app/Http/Controllers/Controller.php"

echo "🔄 RESTORE HTTP KERNEL"
cp "$SRC/app/Http/Kernel.php" "$PANEL/app/Http/Kernel.php"

echo "🧹 REMOVE ALL CUSTOM PROTECT / PATCH"
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
echo "🚀 PANEL WAJIB HIDUP SEKARANG"
