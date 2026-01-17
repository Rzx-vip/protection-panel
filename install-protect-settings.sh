#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"
PROVIDER="$PANEL/app/Providers/AppServiceProvider.php"
ERROR_DIR="$PANEL/resources/views/errors"

DOMAIN="$1"
WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"

if [ -z "$DOMAIN" ] || [ -z "$WA" ]; then
  echo "❌ PARAMETER KURANG"
  exit 1
fi

echo "🚀 INSTALL PROTECT SETTINGS (FINAL • NO 500)"

# ================= BACKUP =================
cp "$PROVIDER" "$PROVIDER.bak_$(date +%s)"

# ================= SAFE PATCH =================
if ! grep -q "PROTECT_SETTINGS_REZZX" "$PROVIDER"; then
  sed -i "/public function boot()/,/^    }/c\\
    public function boot()\\
    {\\
        // === PROTECT_SETTINGS_REZZX ===\\
        if (request()->is('admin/settings*')) {\\
            \$user = auth()->user();\\
            if (!\$user || \$user->id !== 1) {\\
                abort(403);\\
            }\\
        }\\
    }" "$PROVIDER"
fi

# ================= ERROR HTML =================
mkdir -p "$ERROR_DIR"

for CODE in 403 500; do
cat > "$ERROR_DIR/$CODE.blade.php" <<HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>$CODE | Protect Panel RezzX</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
body{
margin:0;background:#020617;color:#e5e7eb;
display:flex;justify-content:center;align-items:center;
min-height:100vh;font-family:Segoe UI,sans-serif
}
.box{text-align:center;max-width:360px}
.avatar{
width:120px;height:120px;border-radius:50%;
background:url("$AVATAR") center/cover no-repeat;
margin:0 auto 20px;box-shadow:0 0 25px rgba(56,189,248,.6)
}
a{
display:inline-block;margin-top:20px;
padding:10px 18px;border-radius:10px;
text-decoration:none;color:#fff;
background:linear-gradient(135deg,#0ea5e9,#6366f1)
}
</style>
</head>
<body>
<div class="box">
<div class="avatar"></div>
<h2>🚫 $CODE | SETTINGS DIPROTEK</h2>
<p>Akses hanya untuk OWNER PANEL</p>
<a href="$DOMAIN/admin">⬅ Kembali</a><br><br>
<a href="$WA">💬 Hubungi Admin</a>
</div>
</body>
</html>
HTML
done

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear
php artisan view:clear
php artisan config:clear

echo "✅ PROTECT SETTINGS AKTIFS"
echo "🔒 /admin/settings*"
echo "🛡️ NO BYPASS • NO 500 • SAFE PATCH"
