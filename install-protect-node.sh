#!/bin/bash

PANEL_PATH="/var/www/pterodactyl"

ERROR_VIEW="$PANEL_PATH/resources/views/errors/403.blade.php"
MIDDLEWARE="$PANEL_PATH/app/Http/Middleware/ProtectNode.php"
KERNEL="$PANEL_PATH/app/Http/Kernel.php"

DOMAIN="$1"
WA="$2"
AVATAR="${3:-https://files.catbox.moe/1s2o5m.jpg}"

echo "🔒 Installing Protect Node (REAL FIX)"

# ================= 403 VIEW =================
cat > "$ERROR_VIEW" << HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Node Protected</title>
<style>
body{
background:#0b1220;
color:#cbd5e1;
font-family:Segoe UI;
display:flex;
justify-content:center;
align-items:center;
height:100vh;
margin:0;
}
.box{text-align:center}
.avatar{
width:120px;
height:120px;
border-radius:50%;
background:url("$AVATAR") center/cover no-repeat;
margin:0 auto 20px;
box-shadow:0 0 20px #6366f1;
}
a{
padding:10px 20px;
background:#6366f1;
color:#fff;
border-radius:10px;
text-decoration:none;
margin:5px;
display:inline-block;
}
</style>
</head>
<body>
<div class="box">
<div class="avatar"></div>
<h2>🚫 NODE DIPROTEK</h2>
<p>Kamu tidak punya izin membuka Node Panel</p>
<a href="$DOMAIN/admin">BACK</a>
<a href="$WA">CHAT ADMIN</a>
</div>
</body>
</html>
HTML

# ================= MIDDLEWARE =================
cat > "$MIDDLEWARE" << 'PHP'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;

class ProtectNode
{
    public function handle($request, Closure $next)
    {
        if (auth()->id() !== 1) {
            abort(403);
        }
        return $next($request);
    }
}
PHP

# ================= REGISTER MIDDLEWARE =================
grep -q ProtectNode "$KERNEL" || sed -i "/'web' => \[/a\        \\Pterodactyl\\Http\\Middleware\\ProtectNode::class," "$KERNEL"

# ================= CLEAR CACHE =================
cd "$PANEL_PATH" || exit
php artisan view:clear
php artisan route:clear
php artisan config:clear

echo "✅ PROTECT NODE AKTIF • NO 500 • NO BYPASS"
