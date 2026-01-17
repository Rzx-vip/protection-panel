#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"

NODE_CONTROLLER="$PANEL/app/Http/Controllers/Admin/Nodes/NodeController.php"
NODE_VIEW_CONTROLLER="$PANEL/app/Http/Controllers/Admin/Nodes/NodeViewController.php"

ERROR_VIEW="$PANEL/resources/views/errors/403.blade.php"

DOMAIN="$1"
URL_WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"

if [ -z "$DOMAIN" ] || [ -z "$URL_WA" ]; then
  echo "PAKAI: bash install.sh https://panel.com https://wa.me/628xxx"
  exit 1
fi

echo "🔥 INSTALL FULL NODE PROTECT (NO BYPASS)"

# ================= BACKUP =================
for f in "$NODE_CONTROLLER" "$NODE_VIEW_CONTROLLER"; do
  [ -f "$f" ] && cp "$f" "$f.bak_$(date +%s)"
done

# ================= NODE CONTROLLER =================
cat > "$NODE_CONTROLLER" << 'PHP'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
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

    public function index(Request $request)
    {
        $nodes = QueryBuilder::for(
            Node::query()->with('location')->withCount('servers')
        )->paginate(25);

        return $this->view->make('admin.nodes.index', ['nodes' => $nodes]);
    }
}
PHP

# ================= NODE VIEW CONTROLLER (INI KUNCI BYPASS) =================
cat > "$NODE_VIEW_CONTROLLER" << 'PHP'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Pterodactyl\Models\Node;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Contracts\View\Factory as ViewFactory;

class NodeViewController extends Controller
{
    public function __construct(private ViewFactory $view)
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403);
        }
    }

    public function index(Request $request, Node $node)
    {
        return $this->view->make('admin.nodes.view.index', ['node' => $node]);
    }

    public function settings(Node $node)
    {
        return $this->view->make('admin.nodes.view.settings', ['node' => $node]);
    }

    public function configuration(Node $node)
    {
        return $this->view->make('admin.nodes.view.configuration', ['node' => $node]);
    }

    public function allocation(Node $node)
    {
        return $this->view->make('admin.nodes.view.allocation', ['node' => $node]);
    }

    public function servers(Node $node)
    {
        return $this->view->make('admin.nodes.view.servers', ['node' => $node]);
    }
}
PHP

# ================= 403 VIEW (HTML LU) =================
mkdir -p "$(dirname "$ERROR_VIEW")"

cat > "$ERROR_VIEW" << HTML
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Protect</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body{
background:#020617;
color:#e5e7eb;
display:flex;
align-items:center;
justify-content:center;
height:100vh;
font-family:Segoe UI,sans-serif
}
.box{text-align:center}
.avatar{
width:120px;height:120px;border-radius:50%;
background:url("$AVATAR") center/cover no-repeat;
margin:0 auto 20px;
box-shadow:0 0 25px rgba(56,189,248,.6)
}
a{color:#38bdf8;text-decoration:none}
</style>
</head>
<body>
<div class="box">
<div class="avatar"></div>
<h2>🚫 403 | NODE DIPROTEK</h2>
<p>Akses hanya untuk OWNER PANEL</p>
<a href="$DOMAIN/admin">⬅ BACK</a><br><br>
<a href="$URL_WA">💬 CHAT ADMIN</a>
</div>
</body>
</html>
HTML

# ================= CLEAR CACHE =================
cd "$PANEL"
php artisan optimize:clear

chmod 644 "$NODE_CONTROLLER" "$NODE_VIEW_CONTROLLER" "$ERROR_VIEW"

echo "✅ FULL NODE PROTECT AKTIF"
echo "🔒 /admin/nodes"
echo "🔒 /admin/nodes/view/*"
echo "❌ NO BYPASS • NO 500 • STABIL"
