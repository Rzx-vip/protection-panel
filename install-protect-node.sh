#!/bin/bash
set -e

PANEL="/var/www/pterodactyl"

NODE_CONTROLLER="$PANEL/app/Http/Controllers/Admin/Nodes/NodeController.php"
NODE_VIEW_CONTROLLER="$PANEL/app/Http/Controllers/Admin/Nodes/NodeViewController.php"

ERROR_VIEW="$PANEL/resources/views/errors/403.blade.php"

DOMAIN="$1"
URL_WA="$2"
AVATAR_URL="$3"

[ -z "$AVATAR_URL" ] && AVATAR_URL="https://files.catbox.moe/1s2o5m.jpg"

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
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>403 | Protect Panel RezzX</title>

<style>
:root {
  --bg: #0b1220;
  --text: #cbd5e1;
  --muted: #64748b;
  --accent: #38bdf8;
  --danger: #ef4444;
}

* {
  box-sizing: border-box;
  font-family: "Segoe UI", sans-serif;
}

body {
  margin: 0;
  background: radial-gradient(circle at top, #0f172a, var(--bg));
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  color: var(--text);
}

.wrapper {
  text-align: center;
  width: 100%;
  padding: 20px;
}

/* HEADER */
.header {
  opacity: .85;
  margin-bottom: 40px;
}

.header span {
  font-size: 26px;
  color: var(--danger);
  margin-right: 8px;
}

.header h1 {
  font-size: 18px;
  font-weight: 500;
  margin: 0;
}

/* AVATAR */
.avatar {
  width: 130px;
  height: 130px;
  margin: 0 auto 15px;
  border-radius: 50%;
  background: url("$AVATAR_URL") center/cover no-repeat;
  box-shadow: 0 0 25px rgba(99,102,241,.6);
  border: 3px solid #020617;
}

/* QUOTE */
.quote {
  font-size: 13px;
  color: var(--muted);
  max-width: 320px;
  margin: 10px auto 18px;
  line-height: 1.5;
}

/* PLAYER */
.player {
  background: #fff;
  color: #000;
  border-radius: 30px;
  padding: 10px 15px;
  max-width: 330px;
  margin: 0 auto 20px;
  box-shadow: 0 10px 25px rgba(0,0,0,.4);
}

audio {
  width: 100%;
}

/* BUTTONS */
.buttons {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-top: 15px;
}

.btn {
  position: relative;
  padding: 12px 22px;
  font-weight: bold;
  border-radius: 12px;
  text-decoration: none;
  color: #fff;
  background: linear-gradient(135deg, #0ea5e9, #6366f1);
  box-shadow: 0 0 18px rgba(56,189,248,.6);
  overflow: hidden;
}

/* SHINE EFFECT */
.btn::before {
  content: "";
  position: absolute;
  top: 0;
  left: -75%;
  width: 50%;
  height: 100%;
  background: linear-gradient(
    120deg,
    transparent,
    rgba(255,255,255,.7),
    transparent
  );
  transform: skewX(-20deg);
  animation: shine 2.5s infinite;
}

@keyframes shine {
  0% { left: -75%; }
  100% { left: 125%; }
}

/* FOOTER */
.footer {
  position: fixed;
  bottom: 15px;
  width: 100%;
  text-align: center;
  font-size: 11px;
  color: var(--muted);
}
</style>
</head>

<body>

<div class="wrapper">

  <div class="header">
    <h1><span>🚫</span>403 | TIDAK DAPAT MEMBUKA NODE<br> KARENA PROTECT AKTIF</h1>
  </div>

  <div class="avatar"></div>

  <div class="quote">
    "Ngapain kau ngintip panel orang?<br>
    Kau bukan pemilik aslinya.<br>
    Hal kecil bisa jadi kejahatan besar."
  </div>

  <div class="player">
    <audio controls autoplay>
      <source src="https://files.catbox.moe/6sbur8.mpeg" type="audio/mpeg">
    </audio>
  </div>

  <div class="buttons">
   <a class="btn" href="$DOMAIN/admin">⬅ BACK</a>
    <a class="btn" href="$URL_WA">💬 CHAT ADMIN</a>
  </div>

</div>

<div class="footer">
  Copyright By RezzX • Panel Pterodactyl Protect
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
