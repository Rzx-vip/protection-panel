#!/bin/bash

# ==========================================
# REZZX VVIP THEME INSTALLER - THE FINAL API 
# ==========================================

CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Menangkap domain dari bot (dikirim lewat $1)
TARGET_DOMAIN=${1:-"Domain Tidak Diset"}

clear
echo -e "${PURPLE}================================================================${NC}"
echo -e "${CYAN}      REZZX VVIP - SANCTUM API INTEGRATION (ANTI ERROR 500)     ${NC}"
echo -e "${PURPLE}================================================================${NC}"
echo -e "${GREEN}[+] Target Domain : $TARGET_DOMAIN${NC}"
echo -e "${GREEN}[+] Menyuntikkan sistem Login VVIP...${NC}"
sleep 1

PTERO_DIR="/var/www/pterodactyl"
WRAPPER="$PTERO_DIR/resources/views/templates/wrapper.blade.php"

if [ ! -f "$WRAPPER" ]; then
    echo -e "${RED}[!] Gagal: Direktori Pterodactyl tidak ditemukan.${NC}"
    exit
fi

# Reset ke file original agar bersih dari error kemarin
if [ ! -f "$WRAPPER.pure.bak" ]; then
    cp $WRAPPER "$WRAPPER.pure.bak"
fi
cp "$WRAPPER.pure.bak" $WRAPPER

TMP_WRAPPER="$PTERO_DIR/resources/views/templates/wrapper.tmp"

cat << 'EOF' > $TMP_WRAPPER
@if (request()->is('auth/login') || request()->is('auth/password'))
<style> body > #app { display: none !important; } </style>
<meta name="csrf-token" content="{{ csrf_token() }}">

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>PANEL PTERODACTYL | REZZX VIP</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&family=Rajdhani:wght@500;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root { --neon-cyan: #00f3ff; --neon-purple: #bc13fe; --neon-green: #00ff88; --neon-red: #ff003c; --bg-dark: #050508; --card-bg: rgba(10, 12, 16, 0.7); --font-title: 'Orbitron', sans-serif; --font-ui: 'Rajdhani', sans-serif; --font-code: 'Fira Code', monospace; }
        * { margin: 0; padding: 0; box-sizing: border-box; user-select: none; -webkit-tap-highlight-color: transparent; }
        body { background-color: var(--bg-dark); color: #fff; font-family: var(--font-ui); min-height: 100dvh; display: flex; flex-direction: column; overflow: hidden; }
        #matrix-canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -2; opacity: 0.35; }
        .vignette { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: radial-gradient(circle at center, transparent 20%, var(--bg-dark) 100%); z-index: -1; pointer-events: none; }
        
        .top-alert { width: 100%; background: #000; border-bottom: 1px solid var(--neon-purple); padding: 8px 10px; text-align: center; font-family: var(--font-code); font-size: 0.75rem; color: #fff; z-index: 100; box-shadow: 0 4px 15px rgba(188, 19, 254, 0.2); display: flex; justify-content: center; align-items: center; min-height: 35px; }
        #alert-text { color: var(--neon-cyan); text-shadow: 0 0 5px var(--neon-cyan); letter-spacing: 1px; }
        .typing-cursor { display: inline-block; width: 6px; height: 12px; background: var(--neon-cyan); margin-left: 5px; animation: blink 0.8s infinite; }
        .mobile-header { width: 100%; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; z-index: 10; background: linear-gradient(180deg, rgba(0,0,0,0.8) 0%, transparent 100%); }
        .brand-logo { font-family: var(--font-title); font-size: 1.5rem; font-weight: 900; color: #fff; text-shadow: 0 0 10px var(--neon-purple); display: flex; align-items: center; gap: 10px; }
        .brand-logo span { color: var(--neon-cyan); }
        .header-right { display: flex; flex-direction: column; align-items: flex-end; gap: 5px; }
        .clock-display { font-family: var(--font-code); font-size: 1rem; font-weight: 700; color: var(--neon-cyan); text-shadow: 0 0 8px rgba(0, 243, 255, 0.5); }
        .date-display { font-size: 0.65rem; color: #888; letter-spacing: 1px; }
        .btn-music { background: rgba(188, 19, 254, 0.1); border: 1px solid var(--neon-purple); color: var(--neon-cyan); width: 32px; height: 32px; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-size: 0.8rem; margin-top: 5px; cursor: pointer; box-shadow: 0 0 10px rgba(188, 19, 254, 0.2); transition: 0.3s; }
        .btn-music.playing { background: var(--neon-purple); color: #fff; animation: pulse 1.5s infinite; }
        .main-container { flex-grow: 1; display: flex; justify-content: center; align-items: center; padding: 20px; z-index: 10; }
        .glass-card { width: 100%; max-width: 400px; background: var(--card-bg); border: 1px solid rgba(0, 243, 255, 0.15); border-radius: 16px; padding: 35px 25px; backdrop-filter: blur(20px); box-shadow: 0 20px 50px rgba(0,0,0,0.8), inset 0 0 20px rgba(0, 243, 255, 0.05); position: relative; }
        .glass-card::before { content: ''; position: absolute; top: 0; left: 10%; width: 80%; height: 2px; background: linear-gradient(90deg, transparent, var(--neon-cyan), transparent); box-shadow: 0 0 15px var(--neon-cyan); }
        .logo-wrapper { text-align: center; margin-bottom: 25px; }
        .ptero-logo { width: 70px; height: 70px; filter: drop-shadow(0 0 10px var(--neon-cyan)); display: block; margin: 0 auto 10px auto; animation: float 4s ease-in-out infinite; }
        .card-title { font-family: var(--font-title); font-size: 1.4rem; letter-spacing: 2px; text-align: center; margin-bottom: 5px; }
        .card-subtitle { font-family: var(--font-code); font-size: 0.75rem; color: var(--neon-purple); letter-spacing: 1px; text-align: center; }
        .input-box { position: relative; margin-bottom: 20px; }
        .input-icon { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #666; font-size: 1rem; transition: 0.3s; pointer-events: none; }
        
        .toggle-password { position: absolute; right: 15px; top: 50%; transform: translateY(-50%); color: #888; font-size: 1rem; cursor: pointer; transition: 0.3s; padding: 5px; z-index: 10; }
        .toggle-password:hover { color: var(--neon-cyan); text-shadow: 0 0 5px var(--neon-cyan); }
        
        .cyber-input { width: 100%; background: rgba(0, 0, 0, 0.4); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 8px; padding: 14px 45px 14px 45px; color: #fff; font-family: var(--font-ui); font-size: 1rem; transition: all 0.3s ease; }
        .cyber-input:focus { border-color: var(--neon-cyan); box-shadow: 0 0 15px rgba(0, 243, 255, 0.1); background: rgba(0, 243, 255, 0.03); outline: none; }
        .cyber-input:focus ~ .input-icon { color: var(--neon-cyan); text-shadow: 0 0 8px var(--neon-cyan); }
        .btn-cyber { width: 100%; padding: 15px; background: var(--neon-cyan); color: #000; border: none; font-family: var(--font-title); font-weight: 700; font-size: 1.1rem; letter-spacing: 1px; cursor: pointer; position: relative; transition: 0.3s; display: flex; justify-content: center; align-items: center; clip-path: polygon(15px 0, 100% 0, 100% calc(100% - 15px), calc(100% - 15px) 100%, 0 100%, 0 15px); }
        .btn-cyber.success { background: var(--neon-green); box-shadow: 0 0 30px rgba(0, 255, 136, 0.5); }
        .btn-cyber.error { background: var(--neon-red); box-shadow: 0 0 30px rgba(255, 0, 60, 0.5); color: #fff; font-size: 0.8rem; letter-spacing: 0px; text-transform: uppercase;}
        .loader-spinner { display: none; width: 20px; height: 20px; border: 3px solid rgba(0,0,0,0.2); border-top-color: #000; border-radius: 50%; animation: spin 0.8s linear infinite; }
        .action-links { margin-top: 15px; display: flex; justify-content: space-between; font-size: 0.85rem; font-weight: 600; }
        .action-link { color: #888; text-decoration: none; transition: 0.3s; }
        .action-link:hover { color: var(--neon-cyan); }
        .cyber-footer { width: 100%; padding: 15px; text-align: center; font-family: var(--font-code); font-size: 0.65rem; color: #555; background: #020202; border-top: 1px solid #111; z-index: 10; position: fixed; bottom: 0; }
        .cyber-footer span { color: var(--neon-purple); }
        @keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0; } }
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }
        @keyframes spin { 100% { transform: rotate(360deg); } }
        @keyframes pulse { 0% { box-shadow: 0 0 0 0 rgba(188, 19, 254, 0.5); } 70% { box-shadow: 0 0 0 10px transparent; } 100% { box-shadow: 0 0 0 0 transparent; } }
    </style>
</head>
<body>
    <canvas id="matrix-canvas"></canvas>
    <div class="vignette"></div>
    <audio id="bg-audio" src="https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"></audio>
    
    <div class="top-alert"><div><i class="fas fa-shield-alt" style="color: var(--neon-purple); margin-right: 5px;"></i><span id="alert-text"></span><span class="typing-cursor"></span></div></div>
    
    <header class="mobile-header">
        <div class="brand-logo"><i class="fas fa-cube" style="color: var(--neon-purple); font-size: 1.2rem;"></i>REZZX<span>VIP</span></div>
        <div class="header-right"><div class="clock-display" id="clock">00:00:00</div><div class="date-display" id="date">SYS_DATE</div><div class="btn-music" id="musicBtn"><i class="fas fa-play" id="musicIcon"></i></div></div>
    </header>

    <main class="main-container">
        <div class="glass-card">
            <div class="logo-wrapper">
                <img src="https://image2url.com/r2/default/images/1771473315834-818db508-f842-4c3c-9df8-02737412d92c.webp" alt="Pterodactyl Logo" class="ptero-logo">
                <h1 class="card-title">SERVER PANEL</h1>
                <p class="card-subtitle">VVIP AUTHENTICATION</p>
            </div>
            
            <form id="authForm">
                <div id="loginInputs">
                    <div class="input-box">
                        <input type="text" id="ptero_user" class="cyber-input" placeholder="Username or Email" required autocomplete="username">
                        <i class="fas fa-user input-icon"></i>
                    </div>
                    <div class="input-box">
                        <input type="password" id="ptero_password" class="cyber-input" placeholder="Password" required autocomplete="current-password">
                        <i class="fas fa-lock input-icon"></i>
                        <i class="fas fa-eye toggle-password" id="togglePasswordBtn"></i>
                    </div>
                </div>
                <button type="submit" class="btn-cyber" id="mainBtn"><span id="btnText">INITIATE LOGIN</span><div class="loader-spinner" id="btnLoader"></div></button>
                <div class="action-links">
                    <a href="/auth/register" class="action-link">Register</a>
                    <a href="/auth/password" class="action-link">Forgot Password?</a>
                </div>
            </form>
        </div>
    </main>

    <footer class="cyber-footer">&copy; 2026 Pterodactyl Software. Modified by <span>REZZX VVIP</span>.</footer>

    <script>
        const alertMsg = "WARNING: UNAUTHORIZED SYSTEM ACCESS WILL BE LOGGED AND BLOCKED BY FIREWALL.";
        const alertEl = document.getElementById('alert-text'); let i = 0; let isDeleting = false;
        function typeAlert() { if(!alertEl) return; if (isDeleting) { alertEl.textContent = alertMsg.substring(0, i - 1); i--; if (i === 0) { isDeleting = false; setTimeout(typeAlert, 500); } else { setTimeout(typeAlert, 20); } } else { alertEl.textContent = alertMsg.substring(0, i + 1); i++; if (i === alertMsg.length) { isDeleting = true; setTimeout(typeAlert, 10000); } else { setTimeout(typeAlert, 60); } } }
        setTimeout(typeAlert, 500);
        function runClock() { const clockEl = document.getElementById('clock'); const dateEl = document.getElementById('date'); if(!clockEl) return; const date = new Date(); clockEl.textContent = date.toLocaleTimeString('en-GB'); dateEl.textContent = date.toLocaleDateString('en-GB', { day:'2-digit', month:'short', year:'numeric' }).toUpperCase().replace(/ /g, '-'); }
        setInterval(runClock, 1000); runClock();
        const audio = document.getElementById('bg-audio'); const btnMusic = document.getElementById('musicBtn'); const iconMusic = document.getElementById('musicIcon');
        if(btnMusic) { btnMusic.addEventListener('click', () => { if(audio.paused) { audio.play(); iconMusic.className = 'fas fa-pause'; btnMusic.classList.add('playing'); } else { audio.pause(); iconMusic.className = 'fas fa-play'; btnMusic.classList.remove('playing'); } }); }
        const cvs = document.getElementById('matrix-canvas'); const ctx = cvs.getContext('2d'); let w = cvs.width = window.innerWidth; let h = cvs.height = window.innerHeight;
        const letters = '0123456789REZZXVVIP'.split(''); const fontSize = 12; const cols = w / fontSize; const drops = []; for(let x = 0; x < cols; x++) drops[x] = 1;
        function drawMatrix() { ctx.fillStyle = 'rgba(5, 5, 8, 0.1)'; ctx.fillRect(0, 0, w, h); ctx.fillStyle = '#bc13fe'; ctx.font = fontSize + 'px monospace'; for(let i = 0; i < drops.length; i++) { const text = letters[Math.floor(Math.random() * letters.length)]; if(Math.random() > 0.8) ctx.fillStyle = '#00f3ff'; else ctx.fillStyle = '#bc13fe'; ctx.fillText(text, i * fontSize, drops[i] * fontSize); if(drops[i] * fontSize > h && Math.random() > 0.975) drops[i] = 0; drops[i]++; } }
        setInterval(drawMatrix, 35); window.addEventListener('resize', () => { w = cvs.width = window.innerWidth; h = cvs.height = window.innerHeight; });

        // TOMBOL MATA PASSWORD
        const togglePasswordBtn = document.getElementById('togglePasswordBtn');
        const passwordInput = document.getElementById('ptero_password');
        togglePasswordBtn.addEventListener('click', function() {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
        });

        // ========================================================
        // API FETCH PTERODACTYL MURNI (ANTI 500)
        // ========================================================
        document.getElementById('authForm').addEventListener('submit', async (e) => {
            e.preventDefault(); 
            const loader = document.getElementById('btnLoader'); 
            const btnText = document.getElementById('btnText'); 
            const mainBtn = document.getElementById('mainBtn');
            
            const userVal = document.getElementById('ptero_user').value;
            const passVal = document.getElementById('ptero_password').value;
            const csrfTokenMeta = document.querySelector('meta[name="csrf-token"]');
            const csrfToken = csrfTokenMeta ? csrfTokenMeta.getAttribute('content') : '';

            btnText.style.display = 'none'; loader.style.display = 'block'; mainBtn.style.pointerEvents = 'none'; mainBtn.classList.remove('error');

            try {
                // WAJIB: Ambil Sanctum Cookie dulu biar nggak ditolak (Error 500)
                await fetch('/sanctum/csrf-cookie', { method: 'GET', headers: { 'X-Requested-With': 'XMLHttpRequest' }});

                // Tembak Login
                const response = await fetch('/auth/login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'X-CSRF-TOKEN': csrfToken,
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: JSON.stringify({ user: userVal, password: passVal })
                });

                if(response.ok || response.redirected) {
                    mainBtn.classList.add('success');
                    loader.style.display = 'none';
                    btnText.textContent = "SUCCESS";
                    btnText.style.display = 'block';
                    setTimeout(() => { window.location.href = '/'; }, 1000);
                } else {
                    loader.style.display = 'none';
                    btnText.textContent = "Username Tidak ditemukan atau password mungkin salah";
                    btnText.style.display = 'block';
                    mainBtn.classList.add('error');
                    setTimeout(() => { mainBtn.classList.remove('error'); btnText.textContent = "INITIATE LOGIN"; mainBtn.style.pointerEvents = 'auto'; }, 4000);
                }
            } catch (err) {
                loader.style.display = 'none';
                btnText.textContent = "KONEKSI TERPUTUS / SERVER ERROR";
                btnText.style.display = 'block';
                mainBtn.classList.add('error');
                setTimeout(() => { mainBtn.classList.remove('error'); btnText.textContent = "INITIATE LOGIN"; mainBtn.style.pointerEvents = 'auto'; }, 4000);
            }
        });
    </script>
</body>
</html>
@else
EOF

cat "$WRAPPER.pure.bak" >> $TMP_WRAPPER
echo "@endif" >> $TMP_WRAPPER
mv $TMP_WRAPPER $WRAPPER

echo -e "${CYAN}[~] Membersihkan Cache Ekstrem...${NC}"
cd $PTERO_DIR
php artisan view:clear > /dev/null 2>&1
php artisan config:clear > /dev/null 2>&1
php artisan cache:clear > /dev/null 2>&1

echo -e "${PURPLE}================================================================${NC}"
echo -e "${GREEN}    FINAL FIX SELESAI! AYO BUKTIKAN SEKARANG!                   ${NC}"
echo -e "${PURPLE}================================================================${NC}"
