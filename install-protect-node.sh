#!/bin/bash
set -euo pipefail

# ==========================================================
# Login UI Kece (D Logo) - Patch built-in /auth/login view
# - Auto-detect view yang dipakai
# - Backup otomatis
# - Clear cache Laravel + Restart PHP-FPM
# ==========================================================

PANEL_DIR="/var/www/pterodactyl"
TS="$(date -u +"%Y-%m-%d-%H-%M-%S")"

DOMAIN="$1"
URL_WA="$2"
AVATAR="$3"

[ -z "$AVATAR" ] && AVATAR="https://files.catbox.moe/1s2o5m.jpg"

# ---------- UI ----------
NC="\033[0m"; BOLD="\033[1m"; DIM="\033[2m"
RED="\033[31m"; GRN="\033[32m"; YLW="\033[33m"; BLU="\033[34m"; CYN="\033[36m"; WHT="\033[37m"
hr(){ echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
ok(){ echo -e "${GRN}✔${NC} $*"; }
info(){ echo -e "${CYN}➜${NC} $*"; }
warn(){ echo -e "${YLW}!${NC} $*"; }
fail(){ echo -e "${RED}✖${NC} $*"; }

trap 'fail "Gagal (exit code: $?). Cek permission/path: '"$PANEL_DIR"'"; exit 1' ERR

banner(){
  clear 2>/dev/null || true
  echo -e "${RED}${BOLD}<html>${NC}"
  echo -e "${RED}${BOLD}  <head>${NC}"
  echo -e "${RED}${BOLD}    <title>LOGIN UI PATCH</title>${NC}"
  echo -e "${RED}${BOLD}  </head>${NC}"
  echo -e "${RED}${BOLD}  <body>${NC}"
  echo -e "${RED}${BOLD}    <h1>⛔ LOGIN UI PATCH ENABLED</h1>${NC}"
  echo -e "${WHT}${BOLD}    <p>Logo: D • Path: /auth/login</p>${NC}"
  echo -e "${RED}${BOLD}  </body>${NC}"
  echo -e "${RED}${BOLD}</html>${NC}"
  hr
}

banner
info "Panel Dir : ${BOLD}${PANEL_DIR}${NC}"

if [ ! -d "$PANEL_DIR" ]; then
  fail "Folder panel tidak ditemukan: $PANEL_DIR"
  exit 1
fi

cd "$PANEL_DIR"

# ---------- 1) Auto-detect login view ----------
info "Mencari view login yang dipakai /auth/login ..."

# cari referensi view('...login...') di app (biar akurat)
CAND="$(grep -RIn --exclude-dir=vendor --exclude-dir=node_modules "view\(['\"][^'\"]*login[^'\"]*['\"]" app 2>/dev/null | head -n 1 || true)"
VIEW_REF=""
if [ -n "$CAND" ]; then
  VIEW_REF="$(echo "$CAND" | sed -n "s/.*view(['\"]\([^'\"]*\)['\"]).*/\1/p" | head -n 1 || true)"
fi

LOGIN_VIEW=""
if [ -n "$VIEW_REF" ]; then
  TRY="resources/views/$(echo "$VIEW_REF" | tr '.' '/')".blade.php
  if [ -f "$TRY" ]; then
    LOGIN_VIEW="$TRY"
  fi
fi

# fallback standar ptero
if [ -z "$LOGIN_VIEW" ] && [ -f "resources/views/auth/login.blade.php" ]; then
  LOGIN_VIEW="resources/views/auth/login.blade.php"
fi

# fallback search
if [ -z "$LOGIN_VIEW" ]; then
  LOGIN_VIEW="$(find resources/views -type f -name "login.blade.php" 2>/dev/null | head -n 1 || true)"
fi

if [ -z "$LOGIN_VIEW" ] || [ ! -f "$LOGIN_VIEW" ]; then
  fail "Gagal menemukan login.blade.php yang dipakai."
  exit 1
fi

ok "Login view ditemukan: ${BOLD}${LOGIN_VIEW}${NC}"
if [ -n "$VIEW_REF" ]; then
  info "View ref: ${DIM}${VIEW_REF}${NC}"
fi

# ---------- 2) Backup + Patch ----------
BACKUP="${LOGIN_VIEW}.bak_${TS}"
cp -a "$LOGIN_VIEW" "$BACKUP"
ok "Backup dibuat: ${BOLD}${BACKUP}${NC}"

info "Menulis UI login baru..."

cat > "$LOGIN_VIEW" <<'EOF'
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
  background: url("$AVATAR") center/cover no-repeat;
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
EOF

chmod 644 "$LOGIN_VIEW"
ok "Login view patched."

# ---------- 3) Clear cache + restart php-fpm (biar langsung keliatan) ----------
info "Clearing Laravel cache/view/route..."
php artisan view:clear >/dev/null 2>&1 || true
php artisan route:clear >/dev/null 2>&1 || true
php artisan cache:clear >/dev/null 2>&1 || true
php artisan config:clear >/dev/null 2>&1 || true
php artisan optimize:clear >/dev/null 2>&1 || true
ok "Cache cleared."

info "Restart PHP-FPM (auto detect)..."
if command -v systemctl >/dev/null 2>&1; then
  mapfile -t PFPM < <(systemctl list-units --type=service --state=running 2>/dev/null | awk '{print $1}' | grep -E '^php([0-9]+\.[0-9]+)?-fpm\.service$' || true)
  if [ "${#PFPM[@]}" -gt 0 ]; then
    for svc in "${PFPM[@]}"; do
      systemctl restart "$svc" || true
      ok "Restarted: $svc"
    done
  else
    warn "Tidak ketemu php*-fpm.service running. Skip restart."
  fi
else
  service php-fpm restart >/dev/null 2>&1 || true
  service php8.2-fpm restart >/dev/null 2>&1 || true
  service php8.1-fpm restart >/dev/null 2>&1 || true
  service php8.0-fpm restart >/dev/null 2>&1 || true
  ok "Restart attempted (service)."
fi

hr
ok "DONE. Buka /auth/login, harus sudah berubah."
info "Backup: ${BOLD}${BACKUP}${NC}"
hr
