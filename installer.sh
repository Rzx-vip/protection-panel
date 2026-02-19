#!/bin/bash

# ==========================================
# REZZX VVIP THEME INSTALLER
# ==========================================

# Definisi Warna untuk Log VVIP
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Efek Animasi Loading
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf " \b\b\b\b"
}

clear
echo -e "${PURPLE}================================================================${NC}"
echo -e "${CYAN}      ██████╗ ███████╗███████╗███████╗██╗  ██╗   ██╗   ██╗██╗██████╗  ${NC}"
echo -e "${CYAN}      ██╔══██╗██╔════╝╚══███╔╝╚══███╔╝╚██╗██╔╝   ██║   ██║██║██╔══██╗ ${NC}"
echo -e "${CYAN}      ██████╔╝█████╗    ███╔╝   ███╔╝  ╚███╔╝    ██║   ██║██║██████╔╝ ${NC}"
echo -e "${CYAN}      ██╔══██╗██╔══╝   ███╔╝   ███╔╝   ██╔██╗    ╚██╗ ██╔╝██║██╔═══╝  ${NC}"
echo -e "${CYAN}      ██║  ██║███████╗███████╗███████╗██╔╝ ██╗    ╚████╔╝ ██║██║      ${NC}"
echo -e "${CYAN}      ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝     ╚═══╝  ╚═╝╚═╝      ${NC}"
echo -e "${PURPLE}================================================================${NC}"
echo -e "${YELLOW}[+] Initiating REZZX VVIP Protocol...${NC}"
sleep 2

# Cek Akses Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] ERROR: Installer ini wajib dijalankan sebagai ROOT.${NC}"
  exit
fi

echo -e "${GREEN}[+] Akses Root Terverifikasi.${NC}"
sleep 1

# Cek Direktori Pterodactyl
PTERO_DIR="/var/www/pterodactyl"
if [ ! -d "$PTERO_DIR" ]; then
    echo -e "${RED}[!] ERROR: Direktori Pterodactyl tidak ditemukan di $PTERO_DIR${NC}"
    exit
fi

echo -e "${CYAN}[~] Membuat Backup Sistem Pterodactyl...${NC}"
(sleep 2) & spinner $!
cp -r $PTERO_DIR/resources/views/templates $PTERO_DIR/resources/views/templates_backup_rezzx
echo -e "${GREEN}[+] Backup berhasil diamankan!${NC}"

echo -e "${CYAN}[~] Menginjeksi Kode HTML/CSS/JS REZZX ke Server...${NC}"
(sleep 3) & spinner $!

# Membuat File Login Custom
cat << 'EOF' > $PTERO_DIR/public/rezzx-login.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>PANEL PTERODACTYL | REZZX VVIP</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&family=Rajdhani:wght@500;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root { --neon-cyan: #00f3ff; --neon-purple: #bc13fe; --neon-green: #00ff88; --bg-dark: #050508; --card-bg: rgba(10, 12, 16, 0.7); --font-title: 'Orbitron', sans-serif; --font-ui: 'Rajdhani', sans-serif; --font-code: 'Fira Code', monospace; }
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
        .glass-card { width: 100%; max-width: 400px; background: var(--card-bg); border: 1px solid rgba(0, 243, 255, 0.15); border-radius: 16px; padding: 35px 25px; backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); box-shadow: 0 20px 50px rgba(0,0,0,0.8), inset 0 0 20px rgba(0, 243, 255, 0.05); position: relative; }
        .glass-card::before { content: ''; position: absolute; top: 0; left: 10%; width: 80%; height: 2px; background: linear-gradient(90deg, transparent, var(--neon-cyan), transparent); box-shadow: 0 0 15px var(--neon-cyan); }
        .logo-wrapper { text-align: center; margin-bottom: 25px; }
        .ptero-logo { width: 70px; height: 70px; filter: drop-shadow(0 0 10px var(--neon-cyan)); margin-bottom: 10px; animation: float 4s ease-in-out infinite; }
        .card-title { font-family: var(--font-title); font-size: 1.4rem; letter-spacing: 2px; }
        .card-subtitle { font-family: var(--font-code); font-size: 0.75rem; color: var(--neon-purple); letter-spacing: 1px; }
        .input-box { position: relative; margin-bottom: 20px; }
        .input-icon { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #666; font-size: 1rem; transition: 0.3s; }
        .cyber-input { width: 100%; background: rgba(0, 0, 0, 0.4); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 8px; padding: 14px 15px 14px 45px; color: #fff; font-family: var(--font-ui); font-size: 1rem; transition: all 0.3s ease; }
        .cyber-input:focus { border-color: var(--neon-cyan); box-shadow: 0 0 15px rgba(0, 243, 255, 0.1); background: rgba(0, 243, 255, 0.03); }
        .cyber-input:focus ~ .input-icon { color: var(--neon-cyan); text-shadow: 0 0 8px var(--neon-cyan); }
        .btn-cyber { width: 100%; padding: 15px; background: var(--neon-cyan); color: #000; border: none; font-family: var(--font-title); font-weight: 700; font-size: 1.1rem; letter-spacing: 1px; cursor: pointer; position: relative; transition: 0.3s; display: flex; justify-content: center; align-items: center; clip-path: polygon(15px 0, 100% 0, 100% calc(100% - 15px), calc(100% - 15px) 100%, 0 100%, 0 15px); }
        .btn-cyber:active { transform: scale(0.96); }
        .btn-cyber.success { background: var(--neon-green); box-shadow: 0 0 30px rgba(0, 255, 136, 0.5); }
        .loader-spinner { display: none; width: 20px; height: 20px; border: 3px solid rgba(0,0,0,0.2); border-top-color: #000; border-radius: 50%; animation: spin 0.8s linear infinite; }
        .action-links { margin-top: 15px; display: flex; justify-content: space-between; font-size: 0.85rem; font-weight: 600; }
        .action-link { color: #888; text-decoration: none; transition: 0.3s; }
        .action-link:hover { color: var(--neon-cyan); }
        .toast { position: fixed; top: -100px; left: 50%; transform: translateX(-50%); background: rgba(10, 20, 15, 0.95); border: 1px solid var(--neon-green); color: var(--neon-green); padding: 12px 25px; border-radius: 8px; font-family: var(--font-ui); font-weight: 700; font-size: 0.9rem; display: flex; align-items: center; gap: 12px; z-index: 9999; box-shadow: 0 10px 30px rgba(0, 255, 136, 0.2); backdrop-filter: blur(10px); transition: top 0.5s cubic-bezier(0.68, -0.55, 0.265, 1.55); width: 90%; max-width: 350px; }
        .toast.show { top: 50px; }
        .cyber-footer { width: 100%; padding: 15px; text-align: center; font-family: var(--font-code); font-size: 0.65rem; color: #555; background: #020202; border-top: 1px solid #111; z-index: 10; }
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
    <div class="toast" id="toast-msg"><i class="fas fa-check-circle" style="font-size: 1.2rem;"></i><span>Kode Reset telah dikirim ke Email!</span></div>
    
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
            
            <form id="authForm" onsubmit="handleAuth(event)">
                <div class="input-box" id="emailBox" style="display: none;"><input type="email" class="cyber-input" id="resetEmail" placeholder="Enter Account Email"><i class="fas fa-envelope input-icon"></i></div>
                <div id="loginInputs">
                    <div class="input-box"><input type="text" class="cyber-input" placeholder="Username or Email" required><i class="fas fa-user input-icon"></i></div>
                    <div class="input-box"><input type="password" class="cyber-input" placeholder="Password" required><i class="fas fa-lock input-icon"></i></div>
                </div>
                <button type="submit" class="btn-cyber" id="mainBtn"><span id="btnText">INITIATE LOGIN</span><div class="loader-spinner" id="btnLoader"></div></button>
                
                <div class="action-links">
                    <span class="action-link" id="registerBtn" style="cursor: pointer;">Register</span>
                    <span class="action-link" id="forgotBtn" style="cursor: pointer;">Forgot Password?</span>
                </div>
            </form>
        </div>
    </main>

    <footer class="cyber-footer">&copy; 2026 Pterodactyl Software. Modified by <span>REZZX VVIP</span>.</footer>

    <script>
        const alertMsg = "WARNING: UNAUTHORIZED SYSTEM ACCESS WILL BE LOGGED AND BLOCKED BY FIREWALL.";
        const alertEl = document.getElementById('alert-text'); let i = 0; let isDeleting = false;
        function typeAlert() { if (isDeleting) { alertEl.textContent = alertMsg.substring(0, i - 1); i--; if (i === 0) { isDeleting = false; setTimeout(typeAlert, 500); } else { setTimeout(typeAlert, 20); } } else { alertEl.textContent = alertMsg.substring(0, i + 1); i++; if (i === alertMsg.length) { isDeleting = true; setTimeout(typeAlert, 10000); } else { setTimeout(typeAlert, 60); } } }
        document.addEventListener('DOMContentLoaded', typeAlert);

        function runClock() { const date = new Date(); document.getElementById('clock').textContent = date.toLocaleTimeString('en-GB'); document.getElementById('date').textContent = date.toLocaleDateString('en-GB', { day:'2-digit', month:'short', year:'numeric' }).toUpperCase().replace(/ /g, '-'); }
        setInterval(runClock, 1000); runClock();

        const audio = document.getElementById('bg-audio'); const btnMusic = document.getElementById('musicBtn'); const iconMusic = document.getElementById('musicIcon');
        btnMusic.addEventListener('click', () => { if(audio.paused) { audio.play(); iconMusic.className = 'fas fa-pause'; btnMusic.classList.add('playing'); } else { audio.pause(); iconMusic.className = 'fas fa-play'; btnMusic.classList.remove('playing'); } });

        const cvs = document.getElementById('matrix-canvas'); const ctx = cvs.getContext('2d'); let w = cvs.width = window.innerWidth; let h = cvs.height = window.innerHeight;
        const letters = '0123456789REZZXVVIP'.split(''); const fontSize = 12; const cols = w / fontSize; const drops = []; for(let x = 0; x < cols; x++) drops[x] = 1;
        function drawMatrix() { ctx.fillStyle = 'rgba(5, 5, 8, 0.1)'; ctx.fillRect(0, 0, w, h); ctx.fillStyle = '#bc13fe'; ctx.font = fontSize + 'px monospace'; for(let i = 0; i < drops.length; i++) { const text = letters[Math.floor(Math.random() * letters.length)]; if(Math.random() > 0.8) ctx.fillStyle = '#00f3ff'; else ctx.fillStyle = '#bc13fe'; ctx.fillText(text, i * fontSize, drops[i] * fontSize); if(drops[i] * fontSize > h && Math.random() > 0.975) drops[i] = 0; drops[i]++; } }
        setInterval(drawMatrix, 35); window.addEventListener('resize', () => { w = cvs.width = window.innerWidth; h = cvs.height = window.innerHeight; });

        let isForgotMode = false; const loginInputs = document.getElementById('loginInputs'); const emailBox = document.getElementById('emailBox'); const btnText = document.getElementById('btnText'); const forgotBtn = document.getElementById('forgotBtn'); const mainBtn = document.getElementById('mainBtn'); const toast = document.getElementById('toast-msg');
        forgotBtn.addEventListener('click', () => { isForgotMode = !isForgotMode; if (isForgotMode) { loginInputs.style.display = 'none'; emailBox.style.display = 'block'; document.getElementById('resetEmail').setAttribute('required', 'true'); btnText.textContent = "SEND RESET LINK"; forgotBtn.textContent = "Back to Login"; } else { emailBox.style.display = 'none'; loginInputs.style.display = 'block'; document.getElementById('resetEmail').removeAttribute('required'); btnText.textContent = "INITIATE LOGIN"; forgotBtn.textContent = "Forgot Password?"; } });

        function handleAuth(e) {
            e.preventDefault(); const loader = document.getElementById('btnLoader'); btnText.style.display = 'none'; loader.style.display = 'block'; mainBtn.style.pointerEvents = 'none';
            if (isForgotMode) { setTimeout(() => { loader.style.display = 'none'; btnText.style.display = 'block'; mainBtn.style.pointerEvents = 'auto'; toast.classList.add('show'); setTimeout(() => { toast.classList.remove('show'); forgotBtn.click(); }, 3000); document.getElementById('authForm').reset(); }, 1500); } else { setTimeout(() => { loader.style.display = 'none'; btnText.textContent = "SYSTEM OVERRIDE SUCCESS"; btnText.style.display = 'block'; mainBtn.classList.add('success'); setTimeout(() => { mainBtn.classList.remove('success'); btnText.textContent = "INITIATE LOGIN"; mainBtn.style.pointerEvents = 'auto'; document.getElementById('authForm').reset(); window.location.href = '/auth/login'; /* Redirect ke login asli Pterodactyl */ }, 2000); }, 2000); }
        }
    </script>
</body>
</html>
EOF

echo -e "${GREEN}[+] File REZZX VVIP berhasil dimuat ke public/rezzx-login.html${NC}"
echo -e "${CYAN}[~] Membersihkan Cache Sistem...${NC}"
cd $PTERO_DIR
php artisan view:clear > /dev/null 2>&1
php artisan config:clear > /dev/null 2>&1
(sleep 2) & spinner $!

echo -e "${PURPLE}================================================================${NC}"
echo -e "${GREEN}                 INSTALASI VVIP SELESAI!                        ${NC}"
echo -e "${PURPLE}================================================================${NC}"
echo -e "${YELLOW}Karya RezzX sudah terpasang. Karena keterbatasan React JS pada${NC}"
echo -e "${YELLOW}Pterodactyl murni, kamu bisa melihat hasil karyamu yang 100%${NC}"
echo -e "${YELLOW}bekerja dengan membuka link berikut di browsermu:${NC}"
echo -e "${CYAN}--> http://IP-SERVER-KAMU/rezzx-login.html ${NC}"
echo -e "${NC}Catatan: Halaman ini berfungsi sebagai Splash Screen/Showcase.${NC}"
echo -e "${PURPLE}================================================================${NC}"
