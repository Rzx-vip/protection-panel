#!/bin/bash
set -e

# ================= CONFIG =================
PANEL="/var/www/pterodactyl"
SETTINGS_DIR="$PANEL/app/Http/Controllers/Admin/Settings"
ERROR_VIEW="$PANEL/resources/views/errors/403.blade.php"
TS=$(date +"%Y%m%d_%H%M%S")

DOMAIN="$1"
WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"
URL_WA="https://wa.me/$WA"

if [ -z "$DOMAIN" ] || [ -z "$WA" ]; then
  echo "❌ CONTOH:"
  echo "bash install.sh https://panel.domain.com 628xxxx"
  exit 1
fi

echo "🚀 INSTALL PROTECT SETTINGS (OWNER ONLY)"

# ================= 403 VIEW =================
mkdir -p "$(dirname "$ERROR_VIEW")"

cat > "$ERROR_VIEW" <<EOF
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>403 | Protect Panel</title>
<style>
* {
  box-sizing: border-box;
  font-family: "Segoe UI", sans-serif;
}
body {
  margin: 0;
  background: #0b1220;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #cbd5e1;
}
.wrapper { text-align: center; padding: 20px; }
.avatar {
  width:130px;height:130px;border-radius:50%;
  background:url("$AVATAR") center/cover no-repeat;
  margin:0 auto 15px;
}
.btn {
  display:inline-block;
  padding:12px 20px;
  margin:8px;
  color:#fff;
  text-decoration:none;
  border-radius:10px;
  background:linear-gradient(135deg,#0ea5e9,#6366f1);
}
.footer {
  position:fixed;
  bottom:15px;
  width:100%;
  font-size:11px;
  opacity:.6;
}
</style>
</head>
<body>
<div class="wrapper">
  <h1>🚫 403 ACCESS DENIED</h1>
  <div class="avatar"></div>
  <p>Panel settings dilindungi.<br>Hanya OWNER yang bisa akses.</p>
  <audio controls autoplay>
    <source src="https://files.catbox.moe/6sbur8.mpeg" type="audio/mpeg">
  </audio>
  <div>
    <a class="btn" href="$DOMAIN/admin">⬅ BACK</a>
    <a class="btn" href="$URL_WA">💬 CHAT ADMIN</a>
  </div>
</div>
<div class="footer">© RezzX • Protect Panel</div>
</body>
</html>
EOF

echo "✅ 403 VIEW OK"

# ================= PATCH FUNCTION =================
patch_controller () {
  FILE="$1"

  [ ! -f "$FILE" ] && { echo "❌ FILE NOT FOUND: $FILE"; exit 1; }

  cp "$FILE" "$FILE.bak_$TS"

  sed -i "/function index/a\\
\\        \$user = \\Illuminate\\Support\\Facades\\Auth::user();\\
\\        if (!\$user || \$user->id !== 1) { abort(403); }\\
" "$FILE"

  sed -i "/function update/a\\
\\        \$user = \\Illuminate\\Support\\Facades\\Auth::user();\\
\\        if (!\$user || \$user->id !== 1) { abort(403); }\\
" "$FILE"

  echo "🔒 PATCHED: $(basename "$FILE")"
}

patch_controller "$SETTINGS_DIR/IndexController.php"
patch_controller "$SETTINGS_DIR/MailController.php"
patch_controller "$SETTINGS_DIR/AdvancedController.php"

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear

echo "✅ PROTECT SETTINGS AKTIF"
echo "👑 ONLY USER ID = 1"
