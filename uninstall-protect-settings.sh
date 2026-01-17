#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
SETTINGS="$PANEL/app/Http/Controllers/Admin/Settings"

echo "🔥 NUKING PROTECT SETTINGS (FULL RESET MODE)"

# ================= SAFETY =================
if [ ! -d "$PANEL" ]; then
  echo "❌ PANEL PATH TIDAK ADA"
  exit 1
fi

cd "$PANEL"

# ================= STEP 1: DELETE SETTINGS CONTROLLERS =================
echo "🧹 Removing broken Settings controllers..."

rm -rf "$SETTINGS"

# ================= STEP 2: RESTORE FROM GIT =================
if [ -d ".git" ]; then
  echo "🔄 Git detected — restoring original files"
  git checkout -- app/Http/Controllers/Admin/Settings
else
  echo "❌ PANEL BUKAN GIT INSTALL"
  echo "📦 Downloading official Settings controllers..."

  mkdir -p "$SETTINGS"

  curl -fsSL https://raw.githubusercontent.com/pterodactyl/panel/develop/app/Http/Controllers/Admin/Settings/IndexController.php \
    -o "$SETTINGS/IndexController.php"

  curl -fsSL https://raw.githubusercontent.com/pterodactyl/panel/develop/app/Http/Controllers/Admin/Settings/MailController.php \
    -o "$SETTINGS/MailController.php"

  curl -fsSL https://raw.githubusercontent.com/pterodactyl/panel/develop/app/Http/Controllers/Admin/Settings/AdvancedController.php \
    -o "$SETTINGS/AdvancedController.php"
fi

chmod -R 644 "$SETTINGS"

# ================= STEP 3: REMOVE CUSTOM ERROR VIEW =================
rm -f "$PANEL/resources/views/errors/403.blade.php"

# ================= STEP 4: CLEAR ALL CACHES =================
php artisan optimize:clear
php artisan view:clear
php artisan route:clear
php artisan config:clear

echo "✅ SETTINGS CONTROLLER RESET SELESAI"
echo "🔓 /admin/settings SUDAH NORMAL"
echo "❌ 500 ERROR MUSNAH"
