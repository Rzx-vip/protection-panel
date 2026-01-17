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
cat > "$ERROR_VIEW" << HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Protect Panel RezzX</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body{
margin:0;background:#020617;color:#e5e7eb;
display:flex;align-items:center;justify-content:center;
height:100vh;font-family:Segoe UI,sans-serif
}
.box{text-align:center;max-width:360px}
.avatar{
width:120px;height:120px;border-radius:50%;
background:url("$AVATAR") center/cover no-repeat;
margin:0 auto 20px;
box-shadow:0 0 30px rgba(56,189,248,.7)
}
p{font-size:13px;color:#94a3b8}
a{
display:inline-block;margin-top:14px;
padding:10px 18px;border-radius:10px;
background:linear-gradient(135deg,#0ea5e9,#6366f1);
color:#fff;text-decoration:none
}
</style>
</head>
<body>
<div class="box">
<div class="avatar"></div>
<h2>🚫 SETTINGS TERKUNCI</h2>
<p>Hanya Owner Panel (ID 1)</p>
<a href="$DOMAIN/admin">⬅ Kembali</a><br><br>
<a href="$WA">💬 Hubungi Owner</a>
</div>
</body>
</html>
HTML

# ================= PATCH INDEX =================
INDEX="$SETTINGS_DIR/IndexController.php"
cp "$INDEX" "$INDEX.bak_$TS"

sed -i "/function index/a\\
        \\$user = \\Illuminate\\\\Support\\\\Facades\\\\Auth::user();\\
        if (!\\$user || \\$user->id !== 1) { abort(403); }\\
" "$INDEX"

sed -i "/function update/a\\
        \\$user = \\Illuminate\\\\Support\\\\Facades\\\\Auth::user();\\
        if (!\\$user || \\$user->id !== 1) { abort(403); }\\
" "$INDEX"

# ================= PATCH MAIL =================
MAIL="$SETTINGS_DIR/MailController.php"
cp "$MAIL" "$MAIL.bak_$TS"

sed -i "/function index/a\\
        \\$user = \\Illuminate\\\\Support\\\\Facades\\\\Auth::user();\\
        if (!\\$user || \\$user->id !== 1) { abort(403); }\\
" "$MAIL"

sed -i "/function update/a\\
        \\$user = \\Illuminate\\\\Support\\\\Facades\\\\Auth::user();\\
        if (!\\$user || \\$user->id !== 1) { abort(403); }\\
" "$MAIL"

# ================= PATCH ADVANCED =================
ADV="$SETTINGS_DIR/AdvancedController.php"
cp "$ADV" "$ADV.bak_$TS"

sed -i "/function index/a\\
        \\$user = \\Illuminate\\\\Support\\\\Facades\\\\Auth::user();\\
        if (!\\$user || \\$user->id !== 1) { abort(403); }\\
" "$ADV"

sed -i "/function update/a\\
        \\$user = \\Illuminate\\\\Support\\\\Facades\\\\Auth::user();\\
        if (!\\$user || \\$user->id !== 1) { abort(403); }\\
" "$ADV"

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear

echo "✅ PROTECT SETTINGS AKTIF"
echo "🔒 /admin/settings"
echo "🔒 /admin/settings/mail"
echo "🔒 /admin/settings/advanced"
echo "👑 ONLY USER ID 1"
