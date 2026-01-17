#!/bin/bash

PANEL="/var/www/pterodactyl"
CONTROLLER="$PANEL/app/Http/Controllers/Admin/Nodes/NodeController.php"
VIEW_DIR="$PANEL/resources/views/errors"
PROTECT_VIEW="$VIEW_DIR/protect-node.blade.php"

echo "🧨 FORCE UNINSTALL PROTECT NODE"

# ================= FORCE RESTORE CONTROLLER =================
echo "🔁 Restoring ORIGINAL NodeController..."

cat > "$CONTROLLER" << 'PHP'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Illuminate\Http\Request;
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

chmod 644 "$CONTROLLER"
echo "✅ NodeController restored (NO PROTECT)"

# ================= REMOVE PROTECT VIEW =================
if [ -f "$PROTECT_VIEW" ]; then
  rm -f "$PROTECT_VIEW"
  echo "🗑️ protect-node.blade.php removed"
else
  echo "ℹ️ protect-node.blade.php not found"
fi

# ================= CLEAR EVERYTHING =================
cd "$PANEL" || exit

php artisan view:clear
php artisan route:clear
php artisan config:clear
php artisan optimize:clear

rm -rf storage/framework/views/*

echo "🧼 Laravel cache nuked"

# ================= PERMISSION =================
chown -R www-data:www-data "$PANEL"
chmod -R 755 "$PANEL/storage"
chmod -R 755 "$PANEL/bootstrap/cache"

echo "🎉 UNINSTALL COMPLETE"
echo "🔓 NODE TAB NORMAL — NO 403 — NO PROTECT"
