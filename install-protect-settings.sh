#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
MIDDLEWARE="$PANEL/app/Http/Middleware/OwnerOnlySettings.php"
KERNEL="$PANEL/app/Http/Kernel.php"
ROUTES="$PANEL/routes/admin.php"
ERROR403="$PANEL/resources/views/errors/403.blade.php"
ERROR500="$PANEL/resources/views/errors/500.blade.php"

DOMAIN="$1"
WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"

if [ -z "$DOMAIN" ] || [ -z "$WA" ]; then
  echo "❌ PARAMETER KURANG"
  exit 1
fi

echo "🚀 INSTALL PROTECT SETTINGS (SAFE • NO 500)"

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
if ! grep -q "OwnerOnlySettings" "$KERNEL"; then
  sed -i "/routeMiddleware = \[/a\\
        'owner.settings' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\OwnerOnlySettings::class,
" "$KERNEL"
fi

# ================= PROTECT ROUTES =================
if ! grep -q "owner.settings" "$ROUTES"; then
  sed -i "/Route::group(\\[.*admin.*\\], function/a\\
    Route::middleware('owner.settings')->group(function () {\\
        Route::get('/settings', 'Settings\\\\IndexController@index');\\
        Route::post('/settings', 'Settings\\\\IndexController@update');\\
        Route::get('/settings/mail', 'Settings\\\\MailController@index');\\
        Route::get('/settings/advanced', 'Settings\\\\AdvancedController@index');\\
    });
" "$ROUTES"
fi

# ================= ERROR HTML (403 & 500) =================
mkdir -p "$(dirname "$ERROR403")"

for ERR in 403 500; do
cat > "$PANEL/resources/views/errors/$ERR.blade.php" << HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>$ERR | Protect Panel RezzX</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body{margin:0;background:#020617;color:#e5e7eb;
display:flex;justify-content:center;align-items:center;height:100vh;
font-family:Segoe UI,sans-serif}
.box{text-align:center;max-width:360px}
.avatar{width:120px;height:120px;border-radius:50%;
background:url("$AVATAR") center/cover no-repeat;
margin:0 auto 20px;
box-shadow:0 0 30px rgba(56,189,248,.7)}
a{display:inline-block;margin-top:14px;padding:10px 18px;
border-radius:10px;background:linear-gradient(135deg,#0ea5e9,#6366f1);
color:#fff;text-decoration:none}
p{font-size:13px;color:#94a3b8}
</style>
</head>
<body>
<div class="box">
<div class="avatar"></div>
<h2>🚫 AKSES DITOLAK</h2>
<p>Menu ini hanya untuk Owner Panel</p>
<a href="$DOMAIN/admin">⬅ Kembali</a><br><br>
<a href="$WA">💬 Hubungi Owner</a>
</div>
</body>
</html>
HTML
done

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear

echo "✅ PROTECT SETTINGS AKTIF"
echo "🔒 /admin/settings"
echo "🔒 /admin/settings/mail"
echo "🔒 /admin/settings/advanced"
echo "🛡️ ANTI BYPASS • ANTI 500"
