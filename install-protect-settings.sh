#!/bin/bash
set -euo pipefail

PANEL="/var/www/pterodactyl"
SETTINGS_DIR="$PANEL/app/Http/Controllers/Admin/Settings"
ERROR_VIEW="$PANEL/resources/views/errors/403.blade.php"
TS=$(date +"%Y%m%d_%H%M%S")

DOMAIN="${1:-}"
WA="${2:-}"
AVATAR="${3:-https://files.catbox.moe/1s2o5m.jpg}"

if [[ -z "$DOMAIN" || -z "$WA" ]]; then
  echo "❌ PARAMETER KURANG"
  echo "CONTOH:"
  echo "bash install-protect-node.sh https://panel.domain.com 628xxxx"
  exit 1
fi

URL_WA="https://wa.me/$WA"

echo "🚀 INSTALL PROTECT SETTINGS (OWNER ONLY)"

# ================= 403 VIEW =================
mkdir -p "$(dirname "$ERROR_VIEW")"

cat > "$ERROR_VIEW" <<EOF
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
.header {
  opacity: .85;
  margin-bottom: 40px;
}
.header span {
  font-size: 26px;
  color: var(--danger);
}
.header h1 {
  font-size: 18px;
  font-weight: 500;
  margin: 0;
}
.avatar {
  width: 130px;
  height: 130px;
  margin: 0 auto 15px;
  border-radius: 50%;
  background: url("$AVATAR") center/cover no-repeat;
  box-shadow: 0 0 25px rgba(99,102,241,.6);
  border: 3px solid #020617;
}
.quote {
  font-size: 13px;
  color: var(--muted);
  max-width: 320px;
  margin: 10px auto 18px;
  line-height: 1.5;
}
.player {
  background: #fff;
  color: #000;
  border-radius: 30px;
  padding: 10px 15px;
  max-width: 330px;
  margin: 0 auto 20px;
}
audio { width: 100%; }
.buttons {
  display: flex;
  justify-content: center;
  gap: 15px;
}
.btn {
  padding: 12px 22px;
  border-radius: 12px;
  text-decoration: none;
  color: #fff;
  background: linear-gradient(135deg, #0ea5e9, #6366f1);
}
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
    <h1><span>🚫</span> 403 | SETTINGS DIKUNCI</h1>
  </div>

  <div class="avatar"></div>

  <div class="quote">
    "Panel ini diproteksi khusus owner.<br>
     Akses ilegal bukan hakmu."
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
  © RezzX • Pterodactyl Protect
</div>

</body>
</html>
EOF

# ================= PATCH CONTROLLER =================
patch_controller () {
  local FILE="$1"
  cp "$FILE" "$FILE.bak_$TS"

  sed -i "/function index/a\\
        \\$user = \\\\Illuminate\\\\Support\\\\Facades\\\\Auth::user();\\
        if (!\\$user || \\$user->id !== 1) { abort(403); }\\
" "$FILE"

  sed -i "/function update/a\\
        \\$user = \\\\Illuminate\\\\Support\\\\Facades\\\\Auth::user();\\
        if (!\\$user || \\$user->id !== 1) { abort(403); }\\
" "$FILE"
}

patch_controller "$SETTINGS_DIR/IndexController.php"
patch_controller "$SETTINGS_DIR/MailController.php"
patch_controller "$SETTINGS_DIR/AdvancedController.php"

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear

echo "✅ PROTECT SETTINGS AKTIF"
echo "🔒 ONLY USER ID 1 (OWNER)"
