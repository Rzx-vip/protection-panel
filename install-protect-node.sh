#!/bin/bash

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
  echo "📌 Contoh:"
  echo "bash install-protect-node.sh https://panel.example.com https://wa.me/62812345678 https://file.catbox.moe/avatar.png"
  exit 1
fi

[ -z "$AVATAR_URL" ] && AVATAR_URL="$DEFAULT_AVATAR"

echo "🚀 Installing PROTECT NODE (STABLE MODE)"

# ================= BACKUP CONTROLLER =================
if [ -f "$CONTROLLER" ]; then
  cp "$CONTROLLER" "$CONTROLLER.bak_$TIMESTAMP"
  echo "📦 Backup NodeController dibuat"
fi

# ================= NODE CONTROLLER (WORKING VERSION) =================
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
    public function __construct(private ViewFactory $view) {}

    public function index(Request $request): View
    {
        $user = Auth::user();

        // 🔒 PROTECT NODE (AMAN, NO 500)
        if (!$user || $user->id !== 1) {
            abort(403);
        }

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

# ================= CUSTOM 403 VIEW (HTML LU PERSIS) =================
mkdir -p "$(dirname "$ERROR_VIEW")"

cat > "$ERROR_VIEW" << HTML
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
  --danger: #ef4444;
}

* { box-sizing: border-box; font-family: "Segoe UI", sans-serif; }

body {
  margin: 0;
  background: radial-gradient(circle at top, #0f172a, var(--bg));
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  color: var(--text);
}

.wrapper { text-align: center; padding: 20px; }

.avatar {
  width: 130px;
  height: 130px;
  margin: 0 auto 15px;
  border-radius: 50%;
  background: url("$AVATAR_URL") center/cover no-repeat;
  box-shadow: 0 0 25px rgba(99,102,241,.6);
}

.btn {
  display: inline-block;
  margin: 10px;
  padding: 12px 22px;
  border-radius: 12px;
  color: #fff;
  text-decoration: none;
  background: linear-gradient(135deg, #0ea5e9, #6366f1);
}
</style>
</head>

<body>
<div class="wrapper">
  <h2>🚫 403 | NODE TERPROTEKSI</h2>
  <div class="avatar"></div>
  <p>Hanya OWNER PANEL yang boleh akses Nodes</p>

  <a class="btn" href="$DOMAIN/admin">⬅ BACK</a>
  <a class="btn" href="$URL_WA">💬 CHAT ADMIN</a>
</div>
</body>
</html>
HTML

# ================= CLEAR CACHE =================
cd "$PANEL_PATH" || exit
php artisan view:clear
php artisan route:clear
php artisan config:clear

chmod 644 "$CONTROLLER"
chmod 644 "$ERROR_VIEW"

echo "✅ PROTECT NODE AKTIF"
echo "🔒 Hanya USER ID 1 bisa buka Nodes"
echo "🧠 Menu lain NORMAL • NO 500 • NO BYPASS"
