#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php"
ERROR_VIEW="/var/www/pterodactyl/resources/views/errors/403.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Nodes + View 403..."

# ================= BACKUP CONTROLLER =================
if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup controller dibuat"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

# ================= 403 VIEW =================
mkdir -p "$(dirname "$ERROR_VIEW")"

cat > "$ERROR_VIEW" <<'EOF'
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>403 | Access Denied</title>
<style>
body{
  margin:0;
  background:#0b1220;
  color:#cbd5e1;
  height:100vh;
  display:flex;
  align-items:center;
  justify-content:center;
  font-family:sans-serif;
}
.box{text-align:center}
a{
  display:inline-block;
  margin-top:15px;
  padding:10px 18px;
  background:#4f46e5;
  color:#fff;
  text-decoration:none;
  border-radius:10px;
}
</style>
</head>
<body>
<div class="box">
<h2>🚫 ACCESS DENIED</h2>
<p>Menu Nodes dilindungi.<br>Hanya OWNER.</p>
<a href="/admin">⬅ Back</a>
</div>
</body>
</html>
EOF

# ================= NODE CONTROLLER =================
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
    public function __construct(private ViewFactory $view)
    {
    }

    public function index(Request $request): View
    {
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            return response()->view('errors.403', [], 403);
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
EOF

chmod 644 "$REMOTE_PATH"

# ================= CLEAR CACHE =================
cd /var/www/pterodactyl || exit
php artisan optimize:clear

echo "✅ Proteksi Nodes + View HTML AKTIF"
echo "🔒 Hanya User ID 1"
