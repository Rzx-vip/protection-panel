#!/bin/bash

# --- DEFINISI LOKASI ---
DIR="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes"

echo "🚑 MEMULAI PERBAIKAN DARURAT (REPAIR KIT)..."

# =======================================================
# 1. KEMBALIKAN NodeController.php (ORIGINAL CODE)
# =======================================================
echo "🔧 Memperbaiki NodeController.php..."

cat > "$DIR/NodeController.php" << 'PHP'
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
    /**
     * NodeController constructor.
     */
    public function __construct(private ViewFactory $view)
    {
    }

    /**
     * Returns a listing of nodes on the system.
     */
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

# =======================================================
# 2. KEMBALIKAN NodeViewController.php (ORIGINAL CODE)
# =======================================================
echo "🔧 Memperbaiki NodeViewController.php..."

cat > "$DIR/NodeViewController.php" << 'PHP'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Pterodactyl\Models\Node;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Contracts\View\Factory as ViewFactory;

class NodeViewController extends Controller
{
    /**
     * NodeViewController constructor.
     */
    public function __construct(private ViewFactory $view)
    {
    }

    /**
     * Returns the index view for a specific node.
     */
    public function index(Request $request, Node $node): View
    {
        return $this->view->make('admin.nodes.view.index', ['node' => $node]);
    }

    /**
     * Returns the settings view for a specific node.
     */
    public function settings(Request $request, Node $node): View
    {
        return $this->view->make('admin.nodes.view.settings', ['node' => $node]);
    }

    /**
     * Return the configuration view for a specific node.
     */
    public function configuration(Request $request, Node $node): View
    {
        return $this->view->make('admin.nodes.view.configuration', ['node' => $node]);
    }

    /**
     * Return the node allocation view.
     */
    public function allocation(Request $request, Node $node): View
    {
        return $this->view->make('admin.nodes.view.allocation', ['node' => $node]);
    }

    /**
     * Return the node server list view.
     */
    public function servers(Request $request, Node $node): View
    {
        return $this->view->make('admin.nodes.view.servers', ['node' => $node]);
    }
}
PHP

# =======================================================
# 3. BERSIHKAN SISA & FIX PERMISSION
# =======================================================
echo "🧹 Membersihkan cache dan memperbaiki izin file..."

# Hapus file view protect jika masih ada
rm -f /var/www/pterodactyl/resources/views/admin/node_protect.blade.php

# Set permission agar bisa dibaca webserver
chmod 644 "$DIR/NodeController.php"
chmod 644 "$DIR/NodeViewController.php"
chown -R www-data:www-data "$DIR"

# Bersihkan Cache Laravel (PENTING UTK ERROR 500)
cd /var/www/pterodactyl
php artisan view:clear
php artisan config:clear
php artisan route:clear

echo "✅ SELESAI! Coba refresh panel kamu sekarang."
