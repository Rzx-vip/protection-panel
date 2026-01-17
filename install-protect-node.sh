#!/bin/bash

# ================= CONFIG =================
PANEL="/var/www/pterodactyl"
ERROR_VIEW="$PANEL/resources/views/errors/403.blade.php"
SETTINGS_CTRL="$PANEL/app/Http/Controllers/Admin/Settings/IndexController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")

DOMAIN="$1"
WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"
URL_WA="https://wa.me/$WA"

echo "🚀 Memasang Protect Settings Panel..."

# ================= VALIDASI =================
if [ -z "$DOMAIN" ] || [ -z "$WA" ]; then
  echo "❌ CONTOH:"
  echo "bash install.sh https://panel.domain.com 628xxxx"
  exit 1
fi

# ================= 403 VIEW =================
mkdir -p "$(dirname "$ERROR_VIEW")"

cat > "$ERROR_VIEW" <<EOF
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Protected</title>
<style>
body{margin:0;background:#0b1220;color:#cbd5e1;
display:flex;align-items:center;justify-content:center;height:100vh;font-family:sans-serif}
.card{text-align:center}
.avatar{width:120px;height:120px;border-radius:50%;
background:url("$AVATAR") center/cover no-repeat;margin:15px auto}
a{display:inline-block;margin:6px;padding:10px 18px;
background:#4f46e5;color:#fff;text-decoration:none;border-radius:10px}
</style>
</head>
<body>
<div class="card">
<h2>🚫 ACCESS DENIED</h2>
<div class="avatar"></div>
<p>Settings panel dilindungi.<br>Hanya OWNER.</p>
<a href="$DOMAIN/admin">⬅ Back</a>
<a href="$URL_WA">💬 Chat Admin</a>
</div>
</body>
</html>
EOF

echo "✅ View 403 dipasang"

# ================= BACKUP =================
if [ -f "$SETTINGS_CTRL" ]; then
  mv "$SETTINGS_CTRL" "$SETTINGS_CTRL.bak_$TIMESTAMP"
  echo "📦 Backup dibuat"
fi

mkdir -p "$(dirname "$SETTINGS_CTRL")"

# ================= CONTROLLER =================
cat > "$SETTINGS_CTRL" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Settings;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;

class IndexController extends Controller
{
    public function index(Request $request): View
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403);
        }

        return view('admin.settings.index');
    }
}
EOF

chmod 644 "$SETTINGS_CTRL"

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear

echo "✅ Protect Settings AKTIF"
echo "🔒 Hanya User ID 1"
