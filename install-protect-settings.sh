#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
MW="$PANEL/app/Http/Middleware/ProtectSettingsOwner.php"
KERNEL="$PANEL/app/Http/Kernel.php"
ERROR_VIEW="$PANEL/resources/views/errors/403.blade.php"
ROUTES="$PANEL/routes/admin.php"

DOMAIN="$1"
WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"

if [ -z "$DOMAIN" ] || [ -z "$WA" ]; then
  echo "❌ PARAMETER KURANG"
  exit 1
fi

echo "🚀 INSTALL PROTECT SETTINGS (ANTI 500 MODE)"

# ================= MIDDLEWARE =================
cat > "$MW" << 'PHP'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;

class ProtectSettingsOwner
{
    public function handle($request, Closure $next)
    {
        $user = Auth::user();

        if (!$user || (int)$user->id !== 1) {
            return response()->view('errors.403', [], 403);
        }

        return $next($request);
    }
}
PHP

# ================= REGISTER MIDDLEWARE =================
if ! grep -q "protect.settings.owner" "$KERNEL"; then
  sed -i "/protected \$routeMiddleware = \[/a\\
        'protect.settings.owner' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ProtectSettingsOwner::class,
" "$KERNEL"
fi

# ================= 403 HTML =================
mkdir -p "$(dirname "$ERROR_VIEW")"
cat > "$ERROR_VIEW" << HTML
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
  background: url("$AVATAR") center/cover no-repeat;
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
    <h1><span>🚫</span>403 | TIDAK DAPAT MEMBUKA SETTINGS<br> KARENA PROTECT AKTIF</h1>
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

# ================= APPLY MIDDLEWARE =================
if ! grep -q "protect.settings.owner" "$ROUTES"; then
  sed -i "s/Route::prefix('settings')/Route::prefix('settings')->middleware('protect.settings.owner')/" "$ROUTES"
fi

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan view:clear
php artisan config:clear
php artisan route:clear

echo "✅ PROTECT SETTINGS AKTIF"
echo "👑 USER ID 1 BYPASS"
echo "🚫 USER LAIN HTML 403 (BUKAN 500)"
