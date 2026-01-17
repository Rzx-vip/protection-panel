#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
MIDDLEWARE="$PANEL/app/Http/Middleware/OwnerOnlySettings.php"
KERNEL="$PANEL/app/Http/Kernel.php"
ROUTES="$PANEL/routes/admin.php"
ERROR403="$PANEL/resources/views/errors/403.blade.php"

DOMAIN="$1"
WA="$2"
AVATAR_URL="$3"

[ -z "$AVATAR_URL" ] && AVATAR_URL="https://files.catbox.moe/1s2o5m.jpg"

if [ -z "$DOMAIN" ] || [ -z "$WA" ]; then
  echo "❌ PARAMETER KURANG"
  exit 1
fi

echo "🚀 INSTALL PROTECT SETTINGS (REAL PROTECTION)"

# ================= MIDDLEWARE =================
cat > "$MIDDLEWARE" << 'PHP'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;

class OwnerOnlySettings
{
    public function handle($request, Closure $next)
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403);
        }
        return $next($request);
    }
}
PHP

# ================= REGISTER MIDDLEWARE =================
if ! grep -q "owner.settings" "$KERNEL"; then
  sed -i "/routeMiddleware = \[/a\\
        'owner.settings' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\OwnerOnlySettings::class,
" "$KERNEL"
fi

# ================= PATCH ROUTES (REAL FIX) =================
if ! grep -q "owner.settings" "$ROUTES"; then
  sed -i "s/Route::group(\\[\\(.*'prefix' => 'settings'.*\\)\\],/Route::group([\\1, 'middleware' => 'owner.settings'],/g" "$ROUTES"
fi

# ================= 403 VIEW =================
mkdir -p "$(dirname "$ERROR403")"

cat > "$ERROR403" << HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Protect Panel RezzX</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
body {
  margin:0;
  background:#020617;
  color:#e5e7eb;
  display:flex;
  justify-content:center;
  align-items:center;
  min-height:100vh;
  font-family:"Segoe UI",sans-serif
}
.box{text-align:center;max-width:360px}
.avatar{
  width:120px;height:120px;border-radius:50%;
  background:url("$AVATAR_URL") center/cover no-repeat;
  margin:0 auto 20px;
  box-shadow:0 0 25px rgba(56,189,248,.6)
}
a{
  display:inline-block;margin-top:20px;
  padding:10px 18px;border-radius:10px;
  text-decoration:none;color:#fff;
  background:linear-gradient(135deg,#0ea5e9,#6366f1)
}
</style>
</head>
<body>
<div class="box">
  <div class="avatar"></div>
  <h2>🚫 403 | SETTINGS DIPROTEK</h2>
  <p>Hanya Owner Panel yang bisa mengakses menu ini.</p>
  <a href="$DOMAIN/admin">⬅ Kembali</a><br><br>
  <a href="$WA">💬 Hubungi Admin</a>
</div>
</body>
</html>
HTML

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear
php artisan route:clear
php artisan view:clear
php artisan config:clear

echo "✅ PROTECT SETTINGS AKTIF (HARD LOCK)"
echo "🔒 /admin/settings"
echo "🔒 /admin/settings/mail"
echo "🔒 /admin/settings/advanced"
