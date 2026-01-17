
#!/bin/bash
set -euo pipefail

# ==========================================================
# Protect Panel By Dezz - Anti Access Nodes (HARD LOCK)
# UI + 403 HTML (SAMA KAYAK LOCK NEST)
# Block:
# - /admin/nodes
# - /admin/nodes/view/{id}
# - /admin/nodes/view/{id}/settings
# - /admin/nodes/view/{id}/configuration
# - /admin/nodes/view/{id}/allocation
# - /admin/nodes/view/{id}/servers
# Notes:
# - Hanya Admin ID 1 yang bisa akses.
# - Non-admin: 403 HTML di SEMUA endpoint Nodes di atas.
# ==========================================================

BASE_DIR="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes"
TIMESTAMP="$(date -u +"%Y-%m-%d-%H-%M-%S")"
# DOMAIN="$1"
URL_WA="${1}"
AVATAR="https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg"

[ -z "$AVATAR" ] && AVATAR="https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg"

FILES=(
  "${BASE_DIR}/NodeController.php"
  "${BASE_DIR}/NodeViewController.php"
  "${BASE_DIR}/NodeSettingsController.php"
  "${BASE_DIR}/NodeConfigurationController.php"
  "${BASE_DIR}/NodeAllocationController.php"
  "${BASE_DIR}/NodeServersController.php"
)

# =========================
# UI - "HTML style" terminal
# =========================
NC="\033[0m"; BOLD="\033[1m"; DIM="\033[2m"
RED="\033[31m"; GRN="\033[32m"; YLW="\033[33m"; BLU="\033[34m"; CYN="\033[36m"; WHT="\033[37m"

hr() { echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

html_screen() {
  clear 2>/dev/null || true
  echo -e "${RED}${BOLD}<html>${NC}"
  echo -e "${RED}${BOLD}  <head>${NC}"
  echo -e "${RED}${BOLD}    <title>PROTECT PANEL</title>${NC}"
  echo -e "${RED}${BOLD}  </head>${NC}"
  echo -e "${RED}${BOLD}  <body>${NC}"
  echo -e "${RED}${BOLD}    <h1>⛔ INTRUSION SHIELD: NODES LOCKDOWN</h1>${NC}"
  echo -e "${WHT}${BOLD}    <p>WM: Protect Panel By Dezz</p>${NC}"
  echo -e "${RED}${BOLD}  </body>${NC}"
  echo -e "${RED}${BOLD}</html>${NC}"
  hr
}

ok()   { echo -e "${GRN}✔${NC} $*"; }
info() { echo -e "${CYN}➜${NC} $*"; }
warn() { echo -e "${YLW}!${NC} $*"; }
fail() { echo -e "${RED}✖${NC} $*"; }

spin() {
  local msg="$1"; shift
  local pid
  local s='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0

  echo -ne "${BLU}${BOLD}${msg}${NC} ${DIM}${s:0:1}${NC}"
  ("$@") >/dev/null 2>&1 &
  pid=$!

  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i + 1) % 10 ))
    echo -ne "\r${BLU}${BOLD}${msg}${NC} ${DIM}${s:$i:1}${NC}"
    sleep 0.08
  done

  wait "$pid"
  echo -ne "\r${BLU}${BOLD}${msg}${NC} ${GRN}DONE${NC}\n"
}

on_error() {
  local code=$?
  echo
  fail "Installer gagal (exit code: $code)"
  echo -e "${DIM}Pastikan jalan sebagai root / permission tulis ke /var/www/pterodactyl.${NC}"
  exit "$code"
}
trap on_error ERR

html_screen
info "Mode     : Installer"
info "Time UTC : ${BOLD}${TIMESTAMP}${NC}"
info "Target   : ${BOLD}${BASE_DIR}${NC}"
hr

spin "Menyiapkan direktori Nodes..." mkdir -p "$BASE_DIR"
chmod 755 "$BASE_DIR"
ok "Direktori siap: $BASE_DIR"
hr

for f in "${FILES[@]}"; do
  backup="${f}.bak_${TIMESTAMP}"
  if [ -f "$f" ]; then
    spin "Backup $(basename "$f")..." mv "$f" "$backup"
    ok "Backup dibuat: ${DIM}${backup}${NC}"
  else
    warn "File tidak ada, akan dibuat baru: $(basename "$f")"
  fi
done

hr
info "Menulis patch proteksi Nodes (HTML 403 + only admin ID 1)..."
hr

# =========================
# 1) NodeController.php
# =========================
cat > "${BASE_DIR}/NodeController.php" <<'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Pterodactyl\Models\Node;
use Spatie\QueryBuilder\QueryBuilder;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Contracts\View\Factory as ViewFactory;
use Illuminate\Support\Facades\Auth;

class NodeController extends Controller
{
    public function __construct(private ViewFactory $view)
    {
        // 🔒 HARD LOCK: semua endpoint Nodes hanya untuk Admin ID 1
        $this->middleware(function ($request, $next) {
            $user = Auth::user();
            if (!$user || (int) $user->id !== 1) {
                return $this->denyHtml();
            }
            return $next($request);
        });
    }

    /**
     * HTML deny page (SAMA KAYAK LOCK NEST).
     */
    private function denyHtml()
    {
        $html = <<<'HTML'
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
  background: url("https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg") center/cover no-repeat;
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
   <a class="btn" href="">⬅ BACK</a>
    <a class="btn" href="${URL_WA}">💬 CHAT ADMIN</a>
  </div>

</div>

<div class="footer">
  Copyright By RezzX • Panel Pterodactyl Protect
</div>

</body>
</html>
HTML;

        return response($html, 403)->header('Content-Type', 'text/html; charset=UTF-8');
    }

    /**
     * /admin/nodes
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
EOF

# =========================
# 2) NodeViewController.php
# =========================
cat > "${BASE_DIR}/NodeViewController.php" <<'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;

/**
 * HARD LOCK controller:
 * - /admin/nodes/view/{id}
 * - /admin/nodes/view/{id}/settings
 * - /admin/nodes/view/{id}/configuration
 * - /admin/nodes/view/{id}/allocation
 * - /admin/nodes/view/{id}/servers
 */
class NodeViewController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            $user = Auth::user();
            if (!$user || (int) $user->id !== 1) {
                return $this->denyHtml();
            }
            return $next($request);
        });
    }

    private function denyHtml()
    {
        $html = <<<'HTML'
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
  background: url("https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg") center/cover no-repeat;
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
   <a class="btn" href="">⬅ BACK</a>
  <a class="btn" href="${URL_WA}">💬 CHAT ADMIN</a>
  </div>

</div>

<div class="footer">
  Copyright By RezzX • Panel Pterodactyl Protect
</div>

</body>
</html>
HTML;

        return response($html, 403)->header('Content-Type', 'text/html; charset=UTF-8');
    }

    public function __invoke(Request $request)
    {
        // kalau route pakai single-action controller
        abort(404);
    }
}
EOF

# =========================
# 3) NodeSettingsController.php
# =========================
cat > "${BASE_DIR}/NodeSettingsController.php" <<'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class NodeSettingsController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            $user = Auth::user();
            if (!$user || (int) $user->id !== 1) {
                return $this->denyHtml();
            }
            return $next($request);
        });
    }

    private function denyHtml()
    {
        $html = <<<'HTML'
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
  background: url("https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg") center/cover no-repeat;
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
   <a class="btn" href="">⬅ BACK</a>
   <a class="btn" href="${URL_WA}">💬 CHAT ADMIN</a>
  </div>

</div>

<div class="footer">
  Copyright By RezzX • Panel Pterodactyl Protect
</div>

</body>
</html>
HTML;

        return response($html, 403)->header('Content-Type', 'text/html; charset=UTF-8');
    }

    public function index(Request $request) { abort(404); }
    public function update(Request $request) { abort(404); }
}
EOF

# =========================
# 4) NodeConfigurationController.php
# =========================
cat > "${BASE_DIR}/NodeConfigurationController.php" <<'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class NodeConfigurationController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            $user = Auth::user();
            if (!$user || (int) $user->id !== 1) {
                return $this->denyHtml();
            }
            return $next($request);
        });
    }

    private function denyHtml()
    {
        $html = <<<'HTML'
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
  background: url("https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg") center/cover no-repeat;
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
   <a class="btn" href="">⬅ BACK</a>
    <a class="btn" href="${URL_WA}">💬 CHAT ADMIN</a>
  </div>

</div>

<div class="footer">
  Copyright By RezzX • Panel Pterodactyl Protect
</div>

</body>
</html>
HTML;

        return response($html, 403)->header('Content-Type', 'text/html; charset=UTF-8');
    }

    public function index(Request $request) { abort(404); }
    public function update(Request $request) { abort(404); }
}
EOF

# =========================
# 5) NodeAllocationController.php
# =========================
cat > "${BASE_DIR}/NodeAllocationController.php" <<'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class NodeAllocationController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            $user = Auth::user();
            if (!$user || (int) $user->id !== 1) {
                return $this->denyHtml();
            }
            return $next($request);
        });
    }

    private function denyHtml()
    {
        $html = <<<'HTML'
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
  background: url("https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg") center/cover no-repeat;
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
   <a class="btn" href="">⬅ BACK</a>
    <a class="btn" href="${URL_WA}">💬 CHAT ADMIN</a>
  </div>

</div>

<div class="footer">
  Copyright By RezzX • Panel Pterodactyl Protect
</div>

</body>
</html>
HTML;

        return response($html, 403)->header('Content-Type', 'text/html; charset=UTF-8');
    }

    public function index(Request $request) { abort(404); }
    public function store(Request $request) { abort(404); }
    public function delete(Request $request) { abort(404); }
}
EOF

# =========================
# 6) NodeServersController.php
# =========================
cat > "${BASE_DIR}/NodeServersController.php" <<'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;

class NodeServersController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            $user = Auth::user();
            if (!$user || (int) $user->id !== 1) {
                return $this->denyHtml();
            }
            return $next($request);
        });
    }

    private function denyHtml()
    {
        $html = <<<'HTML'
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
  background: url("https://i.pinimg.com/736x/9b/77/03/9b7703e7935e9a84f47623d24228bf82.jpg") center/cover no-repeat;
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
   <a class="btn" href="">⬅ BACK</a>
    <a class="btn" href="${URL_WA}">💬 CHAT ADMIN</a>
  </div>

</div>

<div class="footer">
  Copyright By RezzX • Panel Pterodactyl Protect
</div>

</body>
</html>
HTML;

        return response($html, 403)->header('Content-Type', 'text/html; charset=UTF-8');
    }

    public function index(Request $request) { abort(404); }
}
EOF

# permissions
for f in "${FILES[@]}"; do
  chmod 644 "$f"
done

hr
ok "Proteksi Anti Akses Nodes berhasil dipasang (HARD LOCK)!"
info "Folder : ${BOLD}${BASE_DIR}${NC}"
info "WM     : ${BOLD}Protect Panel By Dezz${NC}"
hr
echo -e "${RED}${BOLD}⛔ NODES AREA LOCKED.${NC} ${DIM}(Non-admin akan 403 HTML)${NC}"
hr
