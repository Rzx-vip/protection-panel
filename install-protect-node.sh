#!/bin/bash
set -e

# ================= CONFIG ==================
PANEL_PATH="/var/www/pterodactyl"
CONTROLLER="$PANEL_PATH/app/Http/Controllers/Admin/Nodes/NodeController.php"
ERROR_VIEW="$PANEL_PATH/resources/views/errors/403.blade.php"

DOMAIN="$1"
URL_WA="$2"
AVATAR_URL="$3"

DEFAULT_AVATAR="https://files.catbox.moe/1s2o5m.jpg"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# ================= VALIDATION =================
if [ -z "$DOMAIN" ] || [ -z "$URL_WA" ]; then
  echo "❌ PARAMETER TIDAK LENGKAP"
  exit 1
fi

[ -z "$AVATAR_URL" ] && AVATAR_URL="$DEFAULT_AVATAR"

echo "🚀 Installing PROTECT NODE (NO BYPASS)"

# ================= BACKUP =================
if [ -f "$CONTROLLER" ]; then
  cp "$CONTROLLER" "$CONTROLLER.bak_$TIMESTAMP"
  echo "📦 Backup NodeController dibuat"
fi

# ================= CONTROLLER =================
cat > "$CONTROLLER" << 'PHP'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Models\Node;
use Spatie\QueryBuilder\QueryBuilder;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Contracts\View\Factory as ViewFactory;

class NodeController extends Controller
{
    public function __construct(private ViewFactory $view)
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403);
        }
    }

    public function index(Request $request): View
    {
        $nodes = QueryBuilder::for(
            Node::query()->with('location')->withCount('servers')
        )
        ->allowedFilters(['uuid', 'name'])
        ->allowedSorts(['id'])
        ->paginate(25);

        return $this->view->make('admin.nodes.index', ['nodes' => $nodes]);
    }
}
PHP

# ================= ERROR VIEW =================
mkdir -p "$(dirname "$ERROR_VIEW")"

cat > "$ERROR_VIEW" << HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Protect Node</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
body{margin:0;background:#020617;color:#e5e7eb;
display:flex;justify-content:center;align-items:center;
min-height:100vh;font-family:Segoe UI,sans-serif}
.box{text-align:center;max-width:360px}
.avatar{width:120px;height:120px;border-radius:50%;
background:url("$AVATAR_URL") center/cover no-repeat;
margin:0 auto 20px;box-shadow:0 0 25px #38bdf8}
a{display:inline-block;margin-top:16px;
padding:10px 18px;border-radius:10px;
color:#fff;text-decoration:none;
background:linear-gradient(135deg,#0ea5e9,#6366f1)}
</style>
</head>
<body>
<div class="box">
<div class="avatar"></div>
<h3>🚫 403 | NODE DIPROTEK</h3>
<p>Hanya Admin Utama yang bisa mengakses Node</p>
<a href="$DOMAIN/admin">⬅ Kembali</a><br><br>
<a href="$URL_WA">💬 Chat Admin</a>
</div>
</body>
</html>
HTML

# ================= CLEAR CACHE =================
cd "$PANEL_PATH"
php artisan optimize:clear

chmod 644 "$CONTROLLER" "$ERROR_VIEW"

echo "✅ PROTECT NODE AKTIF 100%"
