#!/bin/bash

# ==========================================
# REZZX VVIP THEME INSTALLER - OFFICIAL MORPHING METHOD
# ==========================================

CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${PURPLE}================================================================${NC}"
echo -e "${CYAN}      REZZX VVIP - PROFESSIONAL SKINNING ENGINE                 ${NC}"
echo -e "${PURPLE}================================================================${NC}"
echo -e "${GREEN}[+] Spek Monster DO 64GB Terdeteksi. Menginstal Tema...${NC}"
sleep 1

PTERO_DIR="/var/www/pterodactyl"
WRAPPER="$PTERO_DIR/resources/views/templates/wrapper.blade.php"

if [ ! -f "$WRAPPER" ]; then
    echo -e "${RED}[!] Gagal: Direktori Pterodactyl tidak ditemukan.${NC}"
    exit
fi

# Backup file murni agar selalu aman
if [ ! -f "$WRAPPER.ori.bak" ]; then
    cp $WRAPPER "$WRAPPER.ori.bak"
    echo -e "${GREEN}[+] Backup original diamankan.${NC}"
fi

# Kembalikan ke original sebelum ditimpa agar tidak dobel
cp "$WRAPPER.ori.bak" $WRAPPER

# ==========================================
# INJEKSI VVIP STYLE KE DALAM KERANGKA PTERODACTYL
# ==========================================
sed -i '/<\/body>/d' $WRAPPER
sed -i '/<\/html>/d' $WRAPPER

cat << 'EOF' >> $WRAPPER

<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&family=Rajdhani:wght@500;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
    /* HANYA AKTIF SAAT DI HALAMAN LOGIN */
    body.is-rezzx-login {
        background-color: #050508 !important;
        font-family: 'Rajdhani', sans-serif !important;
        color: #fff !important;
    }

    /* Menyembunyikan Logo Dinosaurus Bawaan */
    body.is-rezzx-login .md\:max-w-sm svg { display: none !important; }
    
    /* Mengubah Tulisan Bawaan */
    body.is-rezzx-login h2 { display: none !important; }
    body.is-rezzx-login label { color: #00f3ff !important; font-family: 'Fira Code', monospace !important; font-size: 0.75rem !important; }
    body.is-rezzx-login a { color: #bc13fe !important; transition: 0.3s; }
    body.is-rezzx-login a:hover { color: #00f3ff !important; text-shadow: 0 0 5px #00f3ff; }

    /* MENGUBAH FORM BAWAAN MENJADI GLASS CARD VVIP */
    body.is-rezzx-login form {
        background: rgba(10, 12, 16, 0.7) !important;
        backdrop-filter: blur(20px) !important;
        border: 1px solid rgba(0, 243, 255, 0.15) !important;
        box-shadow: 0 20px 50px rgba(0,0,0,0.8), inset 0 0 20px rgba(0, 243, 255, 0.05) !important;
        border-radius: 16px !important;
        padding: 35px 25px !important;
        position: relative;
        overflow: visible !important;
    }
    body.is-rezzx-login form::before {
        content: ''; position: absolute; top: 0; left: 10%; width: 80%; height: 2px;
        background: linear-gradient(90deg, transparent, #00f3ff, transparent);
        box-shadow: 0 0 15px #00f3ff;
    }

    /* MENGUBAH INPUT BAWAAN */
    body.is-rezzx-login input {
        background: rgba(0, 0, 0, 0.4) !important;
        border: 1px solid rgba(255, 255, 255, 0.1) !important;
        color: #fff !important;
        border-radius: 8px !important;
        padding: 12px 15px !important;
        font-family: 'Rajdhani', sans-serif !important;
        font-size: 1rem !important;
        transition: all 0.3s ease !important;
    }
    body.is-rezzx-login input:focus {
        border-color: #00f3ff !important;
        box-shadow: 0 0 15px rgba(0, 243, 255, 0.1) !important;
        background: rgba(0, 243, 255, 0.03) !important;
        outline: none !important;
    }

    /* MENGUBAH TOMBOL LOGIN BAWAAN */
    body.is-rezzx-login button[type="submit"] {
        background: #00f3ff !important;
        color: #000 !important;
        font-family: 'Orbitron', sans-serif !important;
        font-weight: 700 !important;
        font-size: 1.1rem !important;
        letter-spacing: 1px !important;
        border: none !important;
        clip-path: polygon(15px 0, 100% 0, 100% calc(100% - 15px), calc(100% - 15px) 100%, 0 100%, 0 15px) !important;
        border-radius: 0 !important;
        padding: 15px !important;
        margin-top: 15px !important;
        transition: 0.3s !important;
        width: 100% !important;
    }
    body.is-rezzx-login button[type="submit"]:hover {
        box-shadow: 0 0 30px rgba(0, 243, 255, 0.5) !important;
        transform: scale(0.98);
    }
    
    /* Mengubah background abu-abu Pterodactyl */
    body.is-rezzx-login .bg-neutral-900, body.is-rezzx-login .min-h-screen {
        background-color: transparent !important;
    }
    
    /* Tombol Mata Eye Password Custom */
    .rezzx-eye-btn {
        position: absolute; right: 10px; top: 38px; color: #888; font-size: 1.1rem; cursor: pointer; transition: 0.3s; z-index: 50;
    }
    .rezzx-eye-btn:hover { color: #00f3ff; text-shadow: 0 0 5px #00f3ff; }
</style>

<div id="rezzx-vip-elements" style="display: none;">
    <canvas id="matrix-canvas" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -2; opacity: 0.35;"></canvas>
    <div style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: radial-gradient(circle at center, transparent 20%, #050508 100%); z-index: -1; pointer-events: none;"></div>
    
    <div style="position: fixed; top: 0; width: 100%; background: #000; border-bottom: 1px solid #bc13fe; padding: 8px 10px; text-align: center; font-family: 'Fira Code', monospace; font-size: 0.75rem; color: #fff; z-index: 100; box-shadow: 0 4px 15px rgba(188, 19, 254, 0.2);">
        <i class="fas fa-shield-alt" style="color: #bc13fe; margin-right: 5px;"></i>
        <span id="alert-text" style="color: #00f3ff; text-shadow: 0 0 5px #00f3ff; letter-spacing: 1px;">WARNING: UNAUTHORIZED SYSTEM ACCESS WILL BE LOGGED.</span>
    </div>
    
    <header style="position: fixed; top: 35px; width: 100%; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; z-index: 10; background: linear-gradient(180deg, rgba(0,0,0,0.8) 0%, transparent 100%);">
        <div style="font-family: 'Orbitron', sans-serif; font-size: 1.5rem; font-weight: 900; color: #fff; text-shadow: 0 0 10px #bc13fe; display: flex; align-items: center; gap: 10px;">
            <i class="fas fa-cube" style="color: #bc13fe;"></i> REZZX<span style="color: #00f3ff;">VIP</span>
        </div>
        <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 5px;">
            <div id="clock" style="font-family: 'Fira Code', monospace; font-size: 1rem; font-weight: 700; color: #00f3ff; text-shadow: 0 0 8px rgba(0, 243, 255, 0.5);">00:00:00</div>
            <div id="date" style="font-size: 0.65rem; color: #888; letter-spacing: 1px; font-family: 'Rajdhani', sans-serif;">SYS_DATE</div>
        </div>
    </header>
    
    <footer style="position: fixed; bottom: 0; width: 100%; padding: 15px; text-align: center; font-family: 'Fira Code', monospace; font-size: 0.65rem; color: #555; background: #020202; border-top: 1px solid #111; z-index: 10;">
        &copy; 2026 Pterodactyl Software. Modified by <span style="color: #bc13fe;">REZZX VVIP</span>.
    </footer>
</div>

<script>
    // PENGENDALI ENGINE VVIP (Hanya aktif di halaman auth)
    function runRezzxEngine() {
        if (window.location.pathname.includes('/auth/login') || window.location.pathname.includes('/auth/password')) {
            document.body.classList.add('is-rezzx-login');
            document.getElementById('rezzx-vip-elements').style.display = 'block';
            
            const form = document.querySelector('form');
            if(form && !form.dataset.rezzxModified) {
                // Tambahkan Logo & Judul VVIP ke dalam form asli
                const headerHtml = `
                    <div style="text-align: center; margin-bottom: 25px;">
                        <img src="https://image2url.com/r2/default/images/1771473315834-818db508-f842-4c3c-9df8-02737412d92c.webp" style="width: 70px; height: 70px; display: block; margin: 0 auto 10px auto; filter: drop-shadow(0 0 10px #00f3ff); animation: float 4s ease-in-out infinite;">
                        <h1 style="font-family: 'Orbitron', sans-serif; font-size: 1.4rem; letter-spacing: 2px; color: #fff; margin-bottom: 5px;">SERVER PANEL</h1>
                        <p style="font-family: 'Fira Code', monospace; font-size: 0.75rem; color: #bc13fe; letter-spacing: 1px;">VVIP AUTHENTICATION</p>
                    </div>
                `;
                form.insertAdjacentHTML('afterbegin', headerHtml);
                
                // Ubah Teks Tombol Login Asli
                const submitBtn = form.querySelector('button[type="submit"]');
                if(submitBtn) submitBtn.innerText = "INITIATE LOGIN";
                
                // =====================================
                // INJEKSI TOMBOL MATA PASSWORD
                // =====================================
                const passInput = form.querySelector('input[name="password"]');
                if(passInput) {
                    passInput.parentElement.style.position = 'relative';
                    const eyeBtn = document.createElement('i');
                    eyeBtn.className = 'fas fa-eye rezzx-eye-btn';
                    passInput.parentElement.appendChild(eyeBtn);
                    
                    eyeBtn.addEventListener('click', function() {
                        const type = passInput.getAttribute('type') === 'password' ? 'text' : 'password';
                        passInput.setAttribute('type', type);
                        this.className = type === 'password' ? 'fas fa-eye rezzx-eye-btn' : 'fas fa-eye-slash rezzx-eye-btn';
                    });
                }
                
                form.dataset.rezzxModified = 'true';
            }
        } else {
            document.body.classList.remove('is-rezzx-login');
            document.getElementById('rezzx-vip-elements').style.display = 'none';
        }
    }
    
    // Pantau perubahan halaman Pterodactyl SPA
    setInterval(runRezzxEngine, 100);
    
    // Efek Jam & Matrix
    function runClock() { const d = new Date(); document.getElementById('clock').textContent = d.toLocaleTimeString('en-GB'); document.getElementById('date').textContent = d.toLocaleDateString('en-GB', { day:'2-digit', month:'short', year:'numeric' }).toUpperCase().replace(/ /g, '-'); }
    setInterval(runClock, 1000); runClock();
    
    const cvs = document.getElementById('matrix-canvas'); const ctx = cvs.getContext('2d'); let w = cvs.width = window.innerWidth; let h = cvs.height = window.innerHeight;
    const letters = '0123456789REZZXVVIP'.split(''); const fontSize = 12; const cols = w / fontSize; const drops = []; for(let x = 0; x < cols; x++) drops[x] = 1;
    function drawMatrix() { ctx.fillStyle = 'rgba(5, 5, 8, 0.1)'; ctx.fillRect(0, 0, w, h); ctx.fillStyle = '#bc13fe'; ctx.font = fontSize + 'px monospace'; for(let i = 0; i < drops.length; i++) { const text = letters[Math.floor(Math.random() * letters.length)]; if(Math.random() > 0.8) ctx.fillStyle = '#00f3ff'; else ctx.fillStyle = '#bc13fe'; ctx.fillText(text, i * fontSize, drops[i] * fontSize); if(drops[i] * fontSize > h && Math.random() > 0.975) drops[i] = 0; drops[i]++; } }
    setInterval(drawMatrix, 35); window.addEventListener('resize', () => { w = cvs.width = window.innerWidth; h = cvs.height = window.innerHeight; });
    
    // Animasi CSS Float yang dipakai logo
    const style = document.createElement('style');
    style.innerHTML = `@keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }`;
    document.head.appendChild(style);
</script>
</body>
</html>
EOF

echo -e "${CYAN}[~] Membersihkan Cache Laravel Pterodactyl...${NC}"
cd $PTERO_DIR
php artisan view:clear > /dev/null 2>&1
php artisan config:clear > /dev/null 2>&1

echo -e "${PURPLE}================================================================${NC}"
echo -e "${GREEN}    TEMA VVIP BERHASIL DI-INJECT KE MESIN ASLI!                 ${NC}"
echo -e "${PURPLE}================================================================${NC}"
