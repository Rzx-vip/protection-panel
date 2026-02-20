#!/bin/bash

PTERO_DIR="/var/www/pterodactyl"
CTRL_FILE="$PTERO_DIR/app/Http/Controllers/Admin/ApiController.php"
VIEW_FILE="$PTERO_DIR/resources/views/admin/api_protect.blade.php"

echo "🛡️ Memulai Pemasangan Proteksi Application API..."

# 1. BUAT FILE TAMPILAN HTML (Silakan ganti isinya nanti dengan kodemu)
cat > "$VIEW_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 FORBIDDEN | REZZX</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Share+Tech+Mono&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        /* =========================================
           1. CONFIGURATION & VARIABLES
           ========================================= */
        :root {
            --hacker-green: #00ff41;
            --hacker-dark-green: #003b00;
            --bg-color: #020202;
            --glass-bg: rgba(10, 10, 10, 0.92);
            --font-display: 'Orbitron', sans-serif;
            --font-tech: 'Share Tech Mono', monospace;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            user-select: none;
        }

        body {
            background-color: var(--bg-color);
            color: white;
            font-family: var(--font-display);
            height: 100vh;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        /* =========================================
           2. CYBER CLOCK (POJOK KANAN ATAS)
           ========================================= */
        .cyber-clock-container {
            position: absolute;
            top: 20px;
            right: 20px;
            text-align: right;
            z-index: 100;
            border-right: 3px solid var(--hacker-green);
            padding-right: 15px;
            background: rgba(0,0,0,0.5);
            padding: 10px;
            backdrop-filter: blur(5px);
            border-radius: 5px 0 0 5px;
            box-shadow: -5px 5px 15px rgba(0, 255, 65, 0.1);
        }

        #clock-time {
            font-family: var(--font-display);
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--hacker-green);
            letter-spacing: 2px;
            text-shadow: 0 0 10px var(--hacker-green);
        }

        #clock-date {
            font-family: var(--font-tech);
            font-size: 0.8rem;
            color: #ccc;
            letter-spacing: 1px;
            margin-top: 5px;
        }

        /* =========================================
           3. MATRIX BACKGROUND
           ========================================= */
        #canvas {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            opacity: 0.3;
        }

        .overlay-scanline {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(to bottom, rgba(255,255,255,0), rgba(255,255,255,0) 50%, rgba(0,0,0,0.3) 50%, rgba(0,0,0,0.3));
            background-size: 100% 4px;
            z-index: 1;
            pointer-events: none;
        }

        /* =========================================
           4. MAIN CONTENT
           ========================================= */
        .container {
            z-index: 10;
            text-align: center;
            position: relative;
            width: 100%;
            max-width: 800px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* TYPING TEXT - RESPONSIVE FIX */
        .glitch-wrapper {
            margin-bottom: 30px;
            min-height: 60px;
            display: flex;
            justify-content: center;
            align-items: center;
            width: 100%;
        }

        #typing-text {
            font-weight: 900;
            color: var(--hacker-green); /* UBAH JADI HIJAU */
            text-shadow: 0 0 15px var(--hacker-green);
            letter-spacing: 3px;
            line-height: 1.2;
            text-align: center;
        }

        #typing-cursor {
            font-size: 2rem;
            color: white;
            animation: blink 0.8s infinite;
        }

        /* RESPONSIVE FONT SIZE LOGIC */
        /* Desktop */
        @media (min-width: 769px) {
            #typing-text { font-size: 3.5rem; }
            #typing-cursor { font-size: 3.5rem; }
        }
        /* Mobile (HP) */
        @media (max-width: 768px) {
            #typing-text { font-size: 1.8rem; letter-spacing: 1px; } 
            #typing-cursor { font-size: 1.8rem; }
            .container { padding: 10px; }
            .cyber-clock-container { top: 10px; right: 10px; padding: 5px 10px; }
            #clock-time { font-size: 1.1rem; }
        }

        /* =========================================
           5. VIP CARD (GREEN ROTATION)
           ========================================= */
        .vip-card {
            position: relative;
            width: 90%;
            max-width: 500px;
            background: var(--glass-bg);
            border-radius: 20px;
            padding: 3px;
            overflow: hidden;
            box-shadow: 0 0 60px rgba(0,0,0,0.9);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            margin-bottom: 30px;
        }

        /* PENTING: ANIMASI HIJAU SAJA */
        .vip-card::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: conic-gradient(
                transparent, 
                transparent, 
                transparent, 
                var(--hacker-dark-green),
                var(--hacker-green), 
                var(--hacker-green),
                var(--hacker-dark-green),
                transparent
            );
            animation: rotate-border 4s linear infinite;
            z-index: 0;
        }

        .vip-card-inner {
            position: relative;
            background: #050505;
            border-radius: 18px;
            padding: 30px 20px;
            z-index: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 15px;
        }

        .lock-icon {
            font-size: 3.5rem;
            color: var(--hacker-green);
            animation: pulse-green 2s infinite;
            margin-bottom: 5px;
        }

        .card-title {
            font-size: 1.4rem;
            letter-spacing: 2px;
            background: linear-gradient(to right, #fff, #bbb);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .card-desc {
            font-family: var(--font-tech);
            color: #888;
            font-size: 0.85rem;
            line-height: 1.5;
            text-align: center;
        }

        .error-box {
            background: rgba(0, 255, 65, 0.05);
            border: 1px dashed var(--hacker-green);
            color: var(--hacker-green);
            padding: 8px 15px;
            font-size: 0.7rem;
            font-family: var(--font-tech);
            border-radius: 4px;
            margin-top: 10px;
            width: 100%;
            text-align: center;
        }

        /* =========================================
           6. MUSIC PLAYER (WHITE STYLE)
           ========================================= */
        .music-player-container {
            width: 90%;
            max-width: 450px;
            z-index: 20;
        }

        .player-pill {
            background: #eef0f5; /* Putih bersih */
            color: #1a1a1a;
            padding: 12px 20px;
            border-radius: 50px;
            display: flex;
            align-items: center;
            gap: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.6);
            font-family: -apple-system, sans-serif;
            font-weight: 600;
        }

        .play-btn {
            background: none;
            border: none;
            cursor: pointer;
            font-size: 1.2rem;
            color: #000;
            display: flex;
            justify-content: center;
            align-items: center;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background: #ddd;
            transition: 0.2s;
        }
        
        .play-btn:active { transform: scale(0.9); }

        .time-display {
            font-size: 0.8rem;
            min-width: 75px;
            text-align: center;
        }

        .progress-container { flex-grow: 1; display: flex; align-items: center; }

        input[type=range] {
            -webkit-appearance: none;
            width: 100%;
            background: transparent;
        }
        
        input[type=range]::-webkit-slider-thumb {
            -webkit-appearance: none;
            height: 10px;
            width: 10px;
            border-radius: 50%;
            background: #000;
            margin-top: -3px;
        }
        
        input[type=range]::-webkit-slider-runnable-track {
            width: 100%;
            height: 4px;
            background: #bbb;
            border-radius: 2px;
        }
        .footer-info {
            position: fixed;
            bottom: 20px;
            width: 90%;
            max-width: 600px;
            background: rgba(0, 0, 0, 0.9);
            border-top: 2px solid var(--hacker-green);
            padding: 10px;
            font-family: var(--font-tech);
            font-size: 0.75rem;
            color: #666;
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 50;
        }

        .contact-link {
            color: var(--hacker-green);
            text-decoration: none;
            font-weight: bold;
            animation: blink 2s infinite;
        }

        @keyframes rotate-border {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @keyframes pulse-green {
            0% { transform: scale(1); text-shadow: 0 0 10px var(--hacker-green); }
            50% { transform: scale(1.1); text-shadow: 0 0 30px var(--hacker-green); }
            100% { transform: scale(1); text-shadow: 0 0 10px var(--hacker-green); }
        }

        @keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }

        .anim-entry { animation: fadeUp 1s cubic-bezier(0.165, 0.84, 0.44, 1) forwards; opacity: 0; transform: translateY(30px); }
        .anim-entry:nth-child(1) { animation-delay: 0.1s; }
        .anim-entry:nth-child(2) { animation-delay: 0.3s; }
        .anim-entry:nth-child(3) { animation-delay: 0.5s; }

        @keyframes fadeUp { to { opacity: 1; transform: translateY(0); } }

    </style>
</head>
<body>
    <canvas id="canvas"></canvas>
    <div class="overlay-scanline"></div>
    <div class="cyber-clock-container">
        <div id="clock-time">00:00:00</div>
        <div id="clock-date">LOADING DATE...</div>
    </div>
    <div class="container">
        <div class="glitch-wrapper">
            <span id="typing-text"></span><span id="typing-cursor">|</span>
        </div>

        <div class="vip-card anim-entry">
            <div class="vip-card-inner">
                <div class="lock-icon"><i class="fas fa-fingerprint"></i></div>
                <h2 class="card-title">AKSES DITOLAK</h2>
                <p class="card-desc">
                    Hello User,Anda Tidak Dapat Membuka Menu Ini karena Owner Telah mengaktifkan Protect
                </p>
                <div class="error-box">
                    CORE_DUMP: 0x822_ROOT_VIOLATION
                </div>
            </div> 
        </div>
  
        <audio id="bgMusic" loop>
            <source src="https://image2url.com/r2/default/audio/1771466790440-f93287e0-159b-46ca-8dba-99069e245417.mp3" type="audio/mpeg">
        </audio>

        <div class="music-player-container anim-entry">
            <div class="player-pill">
                <button class="play-btn" id="playBtn"><i class="fas fa-play"></i></button>
                <span class="time-display" id="timeDisplay">0:00 / 0:00</span>
                <div class="progress-container">
                    <input type="range" id="progressBar" value="0" min="0" step="1">
                </div>
                <i class="fas fa-volume-up" style="font-size: 0.8rem; color: #888; margin-left: 5px;"></i>
            </div>
        </div>

    </div>
    <div class="footer-info anim-entry">
        <span>PROTECT BY REZZX</span>
        <span>WEBSITE: <a href="https://support.rezzx-rzx.my.id" class="contact-link">REZZX</a></span>
    </div>

    <script>
        function updateClock() {
            const now = new Date();
            const timeString = now.toLocaleTimeString('en-US', { hour12: false });
            const dateString = now.toLocaleDateString('id-ID', { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'short', 
                day: 'numeric' 
            }).toUpperCase();

            document.getElementById('clock-time').innerText = timeString;
            document.getElementById('clock-date').innerText = dateString;
        }
        setInterval(updateClock, 1000);
        updateClock();
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*';
        const fontSize = 14;
        const columns = canvas.width / fontSize;
        const drops = [];

        for(let x = 0; x < columns; x++) drops[x] = 1;

        function draw() {
            ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = '#00ff41'; // Murni Hijau
            ctx.font = fontSize + 'px monospace';

            for(let i = 0; i < drops.length; i++) {
                const text = alphabet.charAt(Math.floor(Math.random() * alphabet.length));
                ctx.fillText(text, i * fontSize, drops[i] * fontSize);
                if(drops[i] * fontSize > canvas.height && Math.random() > 0.975) drops[i] = 0;
                drops[i]++;
            }
        }
        setInterval(draw, 35);
        window.addEventListener('resize', () => { canvas.width = window.innerWidth; canvas.height = window.innerHeight; });
        const textElement = document.getElementById('typing-text');
        const textToType = "403 | ACCESS DENIED";
        let charIndex = 0;
        let isDeleting = false;

        function typeEffect() {
            if (isDeleting) {
                textElement.innerText = textToType.substring(0, charIndex - 1);
                charIndex--;
                if (charIndex === 0) {
                    isDeleting = false;
                    setTimeout(typeEffect, 500);
                } else {
                    setTimeout(typeEffect, 50);
                }
            } else {
                textElement.innerText = textToType.substring(0, charIndex + 1);
                charIndex++;
                if (charIndex === textToType.length) {
                    isDeleting = true;
                    setTimeout(typeEffect, 10000); // Wait 10s
                } else {
                    setTimeout(typeEffect, 100);
                }
            }
        }
        document.addEventListener('DOMContentLoaded', typeEffect);
        const audio = document.getElementById('bgMusic');
        const playBtn = document.getElementById('playBtn');
        const icon = playBtn.querySelector('i');
        const progressBar = document.getElementById('progressBar');
        const timeDisplay = document.getElementById('timeDisplay');

        playBtn.addEventListener('click', () => {
            if (audio.paused) {
                audio.play();
                icon.className = 'fas fa-pause';
            } else {
                audio.pause();
                icon.className = 'fas fa-play';
            }
        });

        audio.addEventListener('timeupdate', () => {
            const current = audio.currentTime;
            const duration = audio.duration;
            if(!isNaN(duration)) {
                progressBar.value = (current / duration) * 100;
                let min = Math.floor(current / 60);
                let sec = Math.floor(current % 60);
                timeDisplay.innerText = `${min}:${sec<10?'0':''}${sec}`;
            }
        });

        progressBar.addEventListener('input', () => {
            const duration = audio.duration;
            audio.currentTime = (progressBar.value / 100) * duration;
        });
        const systemCoreDump = [
            "Initiating kernel sequence...", "Loading drivers: [OK]", "Checking memory integrity...",
            "Address 0x0000F442 verified.", "Encryption key generated: SHA-512",
            "Bypassing firewall level 3...", "Handshake failed on port 443.", "Rerouting to secure channel...",
            "User-Agent blocked by VVIP Protocol.", "Logging IP to blacklist database...",
            "Encrypting file system...", "Locking root directory...", "Access violation at address 0xFFFA",
            "Debugging info: Stack overflow detected.", "Memory leak in module neon_guard.dll",
            "Terminating connection...", "Connection lost.", "Reconnecting...", "Connection Refused.",
            "Displaying error message 403.", "Playing audio alert...", "Rendering canvas matrix...",
            "Loading font resources...", "Optimizing GPU rendering...", "Secure socket layer active.",
            // REPEATING DATA TO INCREASE SIZE
            ...Array(1000).fill("ERROR: 0x8922_ACCESS_VIOLATION | TRACE: 99283-KAJS-112 | SYSTEM_HALT"),
            ...Array(500).fill("WARNING: UNAUTHORIZED ACCESS ATTEMPT DETECTED | IP LOGGED | ADMIN NOTIFIED"),
            ...Array(500).fill("BINARY DUMP: 01010101001010101001010101010010101010101010101010101010101010101")
        ];
        console.log("System loaded with " + systemCoreDump.length + " security protocols.");
    </script>
</body>
</html>
EOF

# 2. BACKUP & REPLACE CONTROLLER
if [ -f "$CTRL_FILE" ]; then
    cp "$CTRL_FILE" "${CTRL_FILE}.bak_ori"
fi

cat > "$CTRL_FILE" << 'PHP'
<?php
namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class ApiController extends Controller
{
    public function index(Request $request)
    {
        // 🔒 BLOKIR SEMUA KECUALI ID 1
        if (Auth::user()->id !== 1) {
            return view('admin.api_protect');
        }
        
        return view('admin.api.index');
    }
}
PHP

# 3. SET PERMISSION & CLEAR CACHE (PENTING BIAR GAK 500 ERROR)
chown www-data:www-data "$CTRL_FILE" "$VIEW_FILE"
chmod 644 "$CTRL_FILE" "$VIEW_FILE"

cd "$PTERO_DIR"
php artisan view:clear
php artisan cache:clear
php artisan route:clear

echo "✅ SELESAI! Proteksi URL Application API berhasil dipasang!"
echo "🎨 File tampilan HTML kamu ada di: $VIEW_FILE"
