#!/bin/bash
set -euo pipefail

# =====================================================
# Protect Panel Pterodactyl - Nodes Hard Lock
# By RezzX
# - Multi Admin ID via jsonbin.io (optional)
# - Fallback ID 1
# =====================================================

IP="$1"
PASS="$2"
DOMAIN="$3"
CHAT_ADMIN="${4:-}"
JSONBIN_URL="${5:-}"

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
            return response()
                ->view('errors.protect-nodes', [], 403);
        }

        return \$next(\$request);
    }
}
EOF

# ===============================
# HTML VIEW (PAKAI HTML KAMU)
# ===============================
mkdir -p "$(dirname "$VIEW")"

cat > "$VIEW" <<EOF
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>403 | Protect Panel RezzX</title>

<style>
$(sed 's/\$/\\$/g' <<'CSS'
:root {
  --bg:#0b1220;--text:#cbd5e1;--muted:#64748b;--danger:#ef4444;
}
body{margin:0;background:radial-gradient(circle at top,#0f172a,var(--bg));
min-height:100vh;display:flex;justify-content:center;align-items:center;color:var(--text);font-family:Segoe UI,sans-serif}
.avatar{width:130px;height:130px;margin:0 auto 15px;border-radius:50%;
background:url("https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg") center/cover no-repeat;
box-shadow:0 0 25px rgba(99,102,241,.6)}
.btn{padding:12px 22px;border-radius:12px;color:#fff;
background:linear-gradient(135deg,#0ea5e9,#6366f1);text-decoration:none;font-weight:bold}
CSS
)
</style>
</head>

<body>
<div style="text-align:center">
<h2 style="color:#ef4444">🚫 403 | NODE AREA LOCKED</h2>
<div class="avatar"></div>

<p>Hanya admin tertentu yang dapat mengakses Node Panel.</p>

<div style="margin-top:20px">
<a class="btn" href="${DOMAIN}/admin">⬅ BACK</a>
EOF

if [ -n "$CHAT_ADMIN" ]; then
  echo "<a class=\"btn\" href=\"$CHAT_ADMIN\">💬 CHAT ADMIN</a>" >> "$VIEW"
fi

cat >> "$VIEW" <<EOF
</div>
</div>
</body>
</html>
EOF

# ===============================
# Register Middleware
# ===============================
grep -q protect.nodes "$KERNEL" || sed -i "/routeMiddleware/a\        'protect.nodes' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ProtectNodes::class," "$KERNEL"

# ===============================
# Inject ke routes/admin.php
# ===============================
sed -i "s/prefix' => 'nodes'/prefix' => 'nodes', 'middleware' => ['protect.nodes']/" "$ROUTES"

# ===============================
# Permission
# ===============================
chown -R www-data:www-data "$BASE"
php artisan view:clear
php artisan route:clear

echo "✅ NODE PROTECTION ACTIVE"
echo "🔒 Allowed Admin: ID 1 ${JSONBIN_URL:+(+ jsonbin.io)}"
