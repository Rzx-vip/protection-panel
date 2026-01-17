#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
MIDDLEWARE="$PANEL/app/Http/Middleware/ProtectSettingsOwner.php"
KERNEL="$PANEL/app/Http/Kernel.php"
ERROR_VIEW="$PANEL/resources/views/errors/403.blade.php"

DOMAIN="$1"
WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"

if [ -z "$DOMAIN" ] || [ -z "$WA" ]; then
  echo "❌ PARAMETER KURANG"
  exit 1
fi

echo "🚀 INSTALL PROTECT SETTINGS (MIDDLEWARE MODE)"

# ================= MIDDLEWARE =================
cat > "$MIDDLEWARE" << 'PHP'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;

class ProtectSettingsOwner
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
if ! grep -q "ProtectSettingsOwner" "$KERNEL"; then
  sed -i "/protected \$routeMiddleware = \[/a\\
        'protect.settings.owner' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ProtectSettingsOwner::class,
" "$KERNEL"
fi

# ================= ERROR VIEW =================
mkdir -p "$(dirname "$ERROR_VIEW")"
cat > "$ERROR_VIEW" << HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Protect Panel RezzX</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
body{margin:0;background:#020617;color:#e5e7eb;display:flex;justify-content:center;align-items:center;min-height:100vh;font-family:Segoe UI}
.box{text-align:center;max-width:360px}
.avatar{width:120px;height:120px;border-radius:50%;background:url("$AVATAR") center/cover no-repeat;margin:0 auto 20px;box-shadow:0 0 25px rgba(56,189,248,.6)}
a{display:inline-block;margin-top:15px;padding:10px 18px;border-radius:10px;text-decoration:none;color:#fff;background:linear-gradient(135deg,#0ea5e9,#6366f1)}
</style>
</head>
<body>
<div class="box">
  <div class="avatar"></div>
  <h3>🚫 SETTINGS DIPROTEK</h3>
  <p>Hanya Owner Panel (ID 1)</p>
  <a href="$DOMAIN/admin">⬅ Kembali</a><br>
  <a href="$WA">💬 Chat Admin</a>
</div>
</body>
</html>
HTML

# ================= APPLY TO ROUTES =================
ROUTES="$PANEL/routes/admin.php"

sed -i "s/Route::prefix('settings')/Route::prefix('settings')->middleware('protect.settings.owner')/" "$ROUTES"

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear

echo "✅ PROTECT SETTINGS AKTIF (ANTI 500)"
echo "🔒 SETTINGS ONLY ID 1"
