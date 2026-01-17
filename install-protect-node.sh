#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php"
ERROR_VIEW="/var/www/pterodactyl/resources/views/errors/403.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

DOMAIN="$1"
URL_WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"

echo "🚀 Memasang Proteksi Nodes..."

# ===== BACKUP =====
if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
mkdir -p "$(dirname "$ERROR_VIEW")"

# ===== 403 VIEW =====
cat > "$ERROR_VIEW" <<EOF
<!DOCTYPE html>
<html>
<head>
<title>403</title>
<style>
body{background:#0b1220;color:#fff;
display:flex;justify-content:center;align-items:center;height:100vh}
.box{text-align:center}
.avatar{width:120px;height:120px;border-radius:50%;
background:url("$AVATAR") center/cover no-repeat;margin:15px auto}
a{color:#fff;text-decoration:none;background:#4f46e5;
padding:10px 16px;border-radius:8px}
</style>
</head>
<body>
<div class="box">
<h2>🚫 ACCESS DENIED</h2>
<div class="avatar"></div>
<p>Menu Nodes dilindungi</p>
<a href="$DOMAIN/admin">⬅ Back</a>
<a href="$URL_WA">💬 Chat Admin</a>
</div>
</body>
</html>
EOF

# ===== CONTROLLER =====
cat > "$REMOTE_PATH" <<'EOF'
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
        if (!$user || $user->id !== 1) {
            return response()->view('errors.403', [], 403);
        }

        $nodes = QueryBuilder::for(
            Node::query()->with('location')->withCount('servers')
        )
        ->paginate(25);

        return $this->view->make('admin.nodes.index', ['nodes' => $nodes]);
    }
}
EOF

chmod 644 "$REMOTE_PATH"

cd /var/www/pterodactyl || exit
php artisan optimize:clear

echo "✅ Proteksi Nodes AKTIF (OWNER ONLY)"
