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
AVATAR_URL="$3"

[ -z "$AVATAR_URL" ] && AVATAR_URL="https://files.catbox.moe/1s2o5m.jpg"

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
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>403 | Protect Panel RezzX</title>

<style>
:root {
  --bg: #0b1220;
  --text: #cbd5e1;
  --muted: #64748b;
  --accent: #38bdf8;
  --danger: #ef4444;
}

* {
  box-sizing: border-box;
  font-family: "Segoe UI", sans-serif;
}

body {
  margin: 0;
  background: radial-gradient(circle at top, #0f172a, var(--bg));
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  color: var(--text);
}

.wrapper {
  text-align: center;
  width: 100%;
  padding: 20px;
}

/* HEADER */
.header {
  opacity: .85;
  margin-bottom: 40px;
}

.header span {
  font-size: 26px;
  color: var(--danger);
  margin-right: 8px;
}

.header h1 {
  font-size: 18px;
  font-weight: 500;
  margin: 0;
}

/* AVATAR */
.avatar {
  width: 130px;
  height: 130px;
  margin: 0 auto 15px;
  border-radius: 50%;
  background: url("$AVATAR_URL") center/cover no-repeat;
  box-shadow: 0 0 25px rgba(99,102,241,.6);
  border: 3px solid #020617;
}

/* QUOTE */
.quote {
  font-size: 13px;
  color: var(--muted);
  max-width: 320px;
  margin: 10px auto 18px;
  line-height: 1.5;
}

/* PLAYER */
.player {
  background: #fff;
  color: #000;
  border-radius: 30px;
  padding: 10px 15px;
  max-width: 330px;
  margin: 0 auto 20px;
  box-shadow: 0 10px 25px rgba(0,0,0,.4);
}

audio {
  width: 100%;
}

/* BUTTONS */
.buttons {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-top: 15px;
}

.btn {
  position: relative;
  padding: 12px 22px;
  font-weight: bold;
  border-radius: 12px;
  text-decoration: none;
  color: #fff;
  background: linear-gradient(135deg, #0ea5e9, #6366f1);
  box-shadow: 0 0 18px rgba(56,189,248,.6);
  overflow: hidden;
}

/* SHINE EFFECT */
.btn::before {
  content: "";
  position: absolute;
  top: 0;
  left: -75%;
  width: 50%;
  height: 100%;
  background: linear-gradient(
    120deg,
    transparent,
    rgba(255,255,255,.7),
    transparent
  );
  transform: skewX(-20deg);
  animation: shine 2.5s infinite;
}

@keyframes shine {
  0% { left: -75%; }
  100% { left: 125%; }
}

/* FOOTER */
.footer {
  position: fixed;
  bottom: 15px;
  width: 100%;
  text-align: center;
  font-size: 11px;
  color: var(--muted);
}
</style>
</head>

<body>

<div class="wrapper">

  <div class="header">
    <h1><span>🚫</span>403 | TIDAK DAPAT MEMBUKA NODE<br> KARENA PROTECT AKTIF</h1>
  </div>

  <div class="avatar"></div>

  <div class="quote">
    "Ngapain kau ngintip panel orang?<br>
    Kau bukan pemilik aslinya.<br>
    Hal kecil bisa jadi kejahatan besar."
  </div>

  <div class="player">
    <audio controls autoplay>
      <source src="https://files.catbox.moe/6sbur8.mpeg" type="audio/mpeg">
    </audio>
  </div>

  <div class="buttons">
   <a class="btn" href="$DOMAIN/admin">⬅ BACK</a>
    <a class="btn" href="$URL_WA">💬 CHAT ADMIN</a>
  </div>

</div>

<div class="footer">
  Copyright By RezzX • Panel Pterodactyl Protect
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
