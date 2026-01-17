#!/bin/bash
set -euo pipefail

# ==========================================
# Protect Panel Pterodactyl - Node Hard Lock
# By RezzX (REAL FINAL, NO 500)
# ==========================================

DOMAIN="${1:-}"
CHAT_ADMIN="${2:-}"
JSONBIN_URL="${3:-}"

BASE="/var/www/pterodactyl"
MW="$BASE/app/Http/Middleware/ProtectNodes.php"
VIEW="$BASE/resources/views/errors/403.blade.php"
KERNEL="$BASE/app/Http/Kernel.php"

[ -z "$DOMAIN" ] && echo "❌ DOMAIN wajib" && exit 1

echo "🔐 Installing NODE Protection (SAFE MODE)..."

# =====================================================
# Middleware (PASTI 403, BUKAN 500)
# =====================================================
cat > "$MW" <<'PHP'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;

class ProtectNodes
{
    public function handle($request, Closure $next)
    {
        if (!str_starts_with($request->path(), 'admin/nodes')) {
            return $next($request);
        }

        $user = Auth::user();
        $allowed = [1];

        $jsonbin = getenv('PTERO_NODE_PROTECT_JSONBIN');
        if ($jsonbin) {
            try {
                $res = Http::timeout(3)->get($jsonbin);
                if ($res->ok() && isset($res['allowed_ids'])) {
                    $allowed = $res['allowed_ids'];
                }
            } catch (\Throwable $e) {}
        }

        if (!$user || !in_array((int)$user->id, $allowed)) {
            abort(403); // ⬅️ PENTING
        }

        return $next($request);
    }
}
PHP

# =====================================================
# HTML ERROR 403 (PAKAI HTML KAMU, TIDAK DIUBAH)
# =====================================================
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
  --bg:#0b1220;--text:#cbd5e1;--muted:#64748b;--accent:#38bdf8;--danger:#ef4444;
}
*{box-sizing:border-box;font-family:"Segoe UI",sans-serif}
body{
margin:0;background:radial-gradient(circle at top,#0f172a,var(--bg));
min-height:100vh;display:flex;justify-content:center;align-items:center;color:var(--text)
}
.wrapper{text-align:center;width:100%;padding:20px}
.avatar{
width:130px;height:130px;margin:0 auto 15px;border-radius:50%;
background:url("https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg") center/cover no-repeat;
box-shadow:0 0 25px rgba(99,102,241,.6);border:3px solid #020617
}
.buttons{display:flex;justify-content:center;gap:15px;margin-top:15px}
.btn{
position:relative;padding:12px 22px;font-weight:bold;border-radius:12px;
text-decoration:none;color:#fff;
background:linear-gradient(135deg,#0ea5e9,#6366f1);
box-shadow:0 0 18px rgba(56,189,248,.6)
}
.footer{position:fixed;bottom:15px;width:100%;text-align:center;font-size:11px;color:var(--muted)}
CSS
)
</style>
</head>
<body>

<div class="wrapper">
  <h1><span style="color:#ef4444">🚫</span> 403 | NODE DIPROTECT</h1>
  <div class="avatar"></div>
  <p>Node ini hanya bisa diakses admin tertentu.</p>

  <div class="buttons">
    <a class="btn" href="${DOMAIN}/admin">⬅ BACK</a>
    <a class="btn" href="${CHAT_ADMIN}">💬 CHAT ADMIN</a>
  </div>
</div>

<div class="footer">
Copyright By RezzX • Panel Pterodactyl Protect
</div>

</body>
</html>
EOF

# =====================================================
# Register Middleware (AMAN)
# =====================================================
grep -q ProtectNodes "$KERNEL" || \
sed -i "/protected \$middlewareGroups = \[/a\        'protect.nodes' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\ProtectNodes::class," "$KERNEL"

# =====================================================
# ENV JSONBIN (AMAN)
# =====================================================
grep -q PTERO_NODE_PROTECT_JSONBIN "$BASE/.env" || \
echo "PTERO_NODE_PROTECT_JSONBIN=${JSONBIN_URL}" >> "$BASE/.env"

# =====================================================
# Clear Cache (WAJIB)
# =====================================================
cd "$BASE"
php artisan optimize:clear

chown -R www-data:www-data "$BASE"

echo "✅ NODE PROTECT ACTIVE (403 ONLY, NO 500)"
