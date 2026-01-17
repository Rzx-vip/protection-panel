#!/bin/bash
set -euo pipefail

# ==============================
# Protect Panel Pterodactyl
# By RezzX (FIXED)
# ==============================

DOMAIN="${1:-}"
CHAT_ADMIN="${2:-}"
JSONBIN_URL="${3:-}"

BASE="/var/www/pterodactyl"
MW="$BASE/app/Http/Middleware/ProtectNodes.php"
VIEW="$BASE/resources/views/errors/protect-nodes.blade.php"
KERNEL="$BASE/app/Http/Kernel.php"
ROUTES="$BASE/routes/admin.php"

[ -z "$DOMAIN" ] && echo "❌ DOMAIN wajib" && exit 1

echo "🔐 Installing Node Protection..."

# ===============================
# Middleware
# ===============================
cat > "$MW" <<EOF
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;

class ProtectNodes
{
    public function handle(\$request, Closure \$next)
    {
        \$user = Auth::user();
        \$allowed = [1];

        \$jsonbin = "${JSONBIN_URL}";
        if (!empty(\$jsonbin)) {
            try {
                \$res = Http::timeout(3)->get(\$jsonbin);
                if (\$res->ok() && isset(\$res['allowed_ids'])) {
                    \$allowed = \$res['allowed_ids'];
                }
            } catch (\Throwable \$e) {}
        }

        if (!\$user || !in_array((int)\$user->id, \$allowed)) {
            return response()->view('errors.protect-nodes', [], 403);
        }

        return \$next(\$request);
    }
}
EOF

# ===============================
# HTML VIEW
# ===============================
mkdir -p "$(dirname "$VIEW")"

cat > "$VIEW" <<EOF
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Node Locked</title>
<style>
body{background:#0b1220;color:#cbd5e1;font-family:sans-serif;
display:flex;align-items:center;justify-content:center;height:100vh}
.btn{padding:12px 20px;border-radius:10px;
background:#6366f1;color:white;text-decoration:none;font-weight:bold}
</style>
</head>
<body>
<div style="text-align:center">
<h2>🚫 NODE AREA LOCKED</h2>
<p>Akses dibatasi untuk admin tertentu.</p>
<a class="btn" href="${DOMAIN}/admin">⬅ BACK</a>
EOF

if [ -n "$CHAT_ADMIN" ]; then
  echo "<br><br><a class=\"btn\" href=\"$CHAT_ADMIN\">💬 CHAT ADMIN</a>" >> "$VIEW"
fi

cat >> "$VIEW" <<EOF
</div>
</body>
</html>
EOF

# ===============================
# Register Middleware
# ===============================
grep -q protect.nodes "$KERNEL" || sed -i "/routeMiddleware/a\        'protect.nodes' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ProtectNodes::class," "$KERNEL"

sed -i "s/prefix' => 'nodes'/prefix' => 'nodes', 'middleware' => ['protect.nodes']/" "$ROUTES"

chown -R www-data:www-data "$BASE"
php artisan view:clear
php artisan route:clear

echo "✅ NODE PROTECTION ACTIVE"
