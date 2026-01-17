#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
SETTINGS_DIR="$PANEL/app/Http/Controllers/Admin/Settings"
ERROR_VIEW="$PANEL/resources/views/errors/403.blade.php"
TS=$(date +"%Y%m%d_%H%M%S")

DOMAIN="$1"
WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"

if [ -z "$DOMAIN" ] || [ -z "$WA" ]; then
  echo "❌ PARAMETER KURANG"
  exit 1
fi

echo "🚀 INSTALL PROTECT SETTINGS (OWNER ONLY)"

# ================= 403 VIEW =================
mkdir -p "$(dirname "$ERROR_VIEW")"
cat > "$ERROR_VIEW" <<HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>403 | Protect Panel RezzX</title>
<style>
body{margin:0;background:#020617;color:#e5e7eb;display:flex;justify-content:center;align-items:center;min-height:100vh;font-family:Segoe UI,sans-serif}
.wrapper{text-align:center;width:100%;padding:20px}
.header{opacity:.85;margin-bottom:40px}
.header span{font-size:26px;color:#ef4444;margin-right:8px}
.header h1{font-size:18px;margin:0;font-weight:500}
.avatar{width:130px;height:130px;margin:0 auto 15px;border-radius:50%;background:url("$AVATAR") center/cover no-repeat;box-shadow:0 0 25px rgba(99,102,241,.6);border:3px solid #020617}
.quote{font-size:13px;color:#64748b;max-width:320px;margin:10px auto 18px;line-height:1.5}
.player{background:#fff;color:#000;border-radius:30px;padding:10px 15px;max-width:330px;margin:0 auto 20px;box-shadow:0 10px 25px rgba(0,0,0,.4)}
audio{width:100%}
.buttons{display:flex;justify-content:center;gap:15px;margin-top:15px}
.btn{position:relative;padding:12px 22px;font-weight:bold;border-radius:12px;text-decoration:none;color:#fff;background:linear-gradient(135deg,#0ea5e9,#6366f1);box-shadow:0 0 18px rgba(56,189,248,.6);overflow:hidden}
.btn::before{content:"";position:absolute;top:0;left:-75%;width:50%;height:100%;background:linear-gradient(120deg,transparent,rgba(255,255,255,.7),transparent);transform:skewX(-20deg);animation:shine 2.5s infinite}
@keyframes shine{0%{left:-75%}100%{left:125%}}
.footer{position:fixed;bottom:15px;width:100%;text-align:center;font-size:11px;color:#64748b}
</style>
</head>
<body>
<div class="wrapper">
<div class="header">
<h1><span>🚫</span>403 | TIDAK DAPAT MEMBUKA SETTINGS<br>KARENA PROTECT AKTIF</h1>
</div>
<div class="avatar"></div>
<div class="quote">
"Ngapain kau ngintip panel orang?<br>Kau bukan pemilik aslinya.<br>Hal kecil bisa jadi kejahatan besar."
</div>
<div class="player">
<audio controls autoplay>
<source src="https://files.catbox.moe/6sbur8.mpeg" type="audio/mpeg">
</audio>
</div>
<div class="buttons">
<a class="btn" href="$DOMAIN/admin">⬅ BACK</a>
<a class="btn" href="$WA">💬 CHAT ADMIN</a>
</div>
</div>
<div class="footer">
Copyright By RezzX • Panel Pterodactyl Protect
</div>
</body>
</html>
HTML

# ================= PATCH CONTROLLERS =================
for CTRL in IndexController MailController AdvancedController; do
  SRC="$SETTINGS_DIR/$CTRL.php"
  if [ -f "$SRC" ]; then
    cp "$SRC" "$SRC.bak_$TS"
    cat > "$SRC" <<PHP
<?php
namespace Pterodactyl\Http\Controllers\Admin\Settings;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;
use Prologue\Alerts\AlertsMessageBag;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Traits\Helpers\AvailableLanguages;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Settings\BaseSettingsFormRequest;

class $CTRL extends Controller
{
    public function index(): View
    {
        \$user = Auth::user();
        if (!\$user || \$user->id !== 1) {
            abort(403);
        }
        return view('admin.settings.${CTRL,,}');
    }

    public function update(BaseSettingsFormRequest \$request): RedirectResponse
    {
        \$user = Auth::user();
        if (!\$user || \$user->id !== 1) {
            abort(403);
        }
        return redirect()->route('admin.settings');
    }
}
PHP
  fi
done

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear
php artisan view:clear
php artisan config:clear

echo "✅ PROTECT SETTINGS AKTIF TOTAL"
echo "🔒 /admin/settings"
echo "🔒 /admin/settings/mail"
echo "🔒 /admin/settings/advanced"
echo "👑 ONLY USER ID 1"
