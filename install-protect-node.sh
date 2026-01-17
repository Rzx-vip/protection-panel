#!/bin/bash
set -e

PANEL_PATH="/var/www/pterodactyl"
CONTROLLER="$PANEL_PATH/app/Http/Controllers/Admin/Nodes/NodeController.php"
ERROR_VIEW="$PANEL_PATH/resources/views/errors/403.blade.php"

DOMAIN="$1"
URL_WA="$2"
AVATAR_URL="$3"

[ -z "$AVATAR_URL" ] && AVATAR_URL="https://files.catbox.moe/1s2o5m.jpg"

if [ -z "$DOMAIN" ] || [ -z "$URL_WA" ]; then
  echo "PARAMETER KURANG"
  exit 1
fi

echo "INSTALL PROTECT NODE..."

cp "$CONTROLLER" "$CONTROLLER.bak_$(date +%s)" 2>/dev/null || true

cat > "$CONTROLLER" << 'PHP'
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

mkdir -p "$(dirname "$ERROR_VIEW")"

cat > "$ERROR_VIEW" << HTML
<!DOCTYPE html>
<html><head><title>403</title></head>
<body style="background:#020617;color:white;display:flex;justify-content:center;align-items:center;height:100vh">
<div style="text-align:center">
<img src="$AVATAR_URL" width="120" style="border-radius:50%"><br><br>
<h2>403 | NODE DIPROTEK</h2>
<a href="$DOMAIN/admin" style="color:#38bdf8">BACK</a><br>
<a href="$URL_WA" style="color:#38bdf8">CHAT ADMIN</a>
</div>
</body></html>
HTML

cd "$PANEL_PATH"
php artisan optimize:clear

chmod 644 "$CONTROLLER" "$ERROR_VIEW"

echo "SELESAI"
