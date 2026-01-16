#!/bin/bash

PANEL_PATH="/var/www/pterodactyl"
CONTROLLER="$PANEL_PATH/app/Http/Controllers/Admin/Nodes/NodeController.php"
VIEW_PATH="$PANEL_PATH/resources/views/errors"
VIEW_FILE="$VIEW_PATH/protect-node.blade.php"

DOMAIN="$1"
URL_WA="$2"
AVATAR_URL="$3"

DEFAULT_AVATAR="https://files.catbox.moe/1s2o5m.jpg"

[ -z "$AVATAR_URL" ] && AVATAR_URL="$DEFAULT_AVATAR"

echo "🔒 Installing Protect Node (SAFE MODE)"

# ================= VIEW =================
mkdir -p "$VIEW_PATH"

cat > "$VIEW_FILE" << HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Node Protected</title>
<style>
body{
  margin:0;
  background:#0b1220;
  color:#cbd5e1;
  font-family:Segoe UI;
  display:flex;
  align-items:center;
  justify-content:center;
  height:100vh;
}
.box{
  text-align:center;
}
.avatar{
  width:130px;
  height:130px;
  border-radius:50%;
  background:url("$AVATAR_URL") center/cover no-repeat;
  margin:0 auto 20px;
  box-shadow:0 0 25px #6366f1;
}
a{
  display:inline-block;
  margin:10px;
  padding:10px 20px;
  border-radius:10px;
  background:#6366f1;
  color:#fff;
  text-decoration:none;
}
</style>
</head>
<body>
<div class="box">
  <div class="avatar"></div>
  <h2>🚫 NODE DIPROTEK</h2>
  <p>Kamu tidak punya akses ke menu node</p>
  <a href="$DOMAIN/admin">BACK</a>
  <a href="$URL_WA">CHAT ADMIN</a>
</div>
</body>
</html>
HTML

# ================= CONTROLLER PATCH (AMAN) =================
grep -q "protect-node" "$CONTROLLER" || sed -i '/public function index(/a\
        if (!auth()->check() || auth()->id() !== 1) {\
            return response()->view("errors.protect-node", [], 403);\
        }\
' "$CONTROLLER"

# ================= PERMISSION =================
chmod 644 "$VIEW_FILE"

# ================= CLEAR CACHE =================
cd "$PANEL_PATH" || exit 1
php artisan view:clear
php artisan route:clear
php artisan config:clear

echo "✅ PROTECT NODE AKTIF & STABIL"
