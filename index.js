// Nama file di GitHub: theme-installer.js
const fs = require('fs');
const path = require('path');

const pteroPath = '/var/www/pterodactyl';
const wrapperPath = path.join(pteroPath, 'resources/views/templates/wrapper.blade.php');

console.log("[RezzX Engine] Memulai instalasi tema VVIP...");

// 1. KODE HTML & CSS VVIP KAMU
const vvipCode = `
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&family=Rajdhani:wght@500;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    /* Mengubah Tampilan Dasar Seluruh Halaman Login */
    body { background-color: #050508 !important; font-family: 'Rajdhani', sans-serif !important; color: #fff; }
    
    /* MENGHILANGKAN LOGO DINOSAURUS ASLI */
    .md\\:max-w-sm svg { display: none !important; }
    h2 { display: none !important; } /* Hilangkan teks Sign In */

    /* GLASS CARD VVIP UNTUK FORM ASLI */
    form {
        background: rgba(10, 12, 16, 0.7) !important;
        backdrop-filter: blur(20px) !important;
        border: 1px solid rgba(0, 243, 255, 0.15) !important;
        box-shadow: 0 20px 50px rgba(0,0,0,0.8), inset 0 0 20px rgba(0, 243, 255, 0.05) !important;
        border-radius: 16px !important;
        padding: 35px 25px !important;
        position: relative; z-index: 100;
    }
    form::before {
        content: ''; position: absolute; top: 0; left: 10%; width: 80%; height: 2px;
        background: linear-gradient(90deg, transparent, #00f3ff, transparent);
        box-shadow: 0 0 15px #00f3ff;
    }

    /* KUSTOMISASI INPUT PTERODACTYL */
    input {
        background: rgba(0, 0, 0, 0.4) !important;
        border: 1px solid rgba(255, 255, 255, 0.1) !important;
        color: #fff !important;
        border-radius: 8px !important;
        padding: 14px 15px !important;
    }
    input:focus { border-color: #00f3ff !important; box-shadow: 0 0 15px rgba(0, 243, 255, 0.1) !important; }

    /* KUSTOMISASI TOMBOL LOGIN ASLI */
    button[type="submit"] {
        background: #00f3ff !important; color: #000 !important; font-family: 'Orbitron', sans-serif !important;
        font-weight: 700 !important; font-size: 1.1rem !important;
        clip-path: polygon(15px 0, 100% 0, 100% calc(100% - 15px), calc(100% - 15px) 100%, 0 100%, 0 15px) !important;
        border-radius: 0 !important; transition: 0.3s !important; margin-top: 15px !important;
    }
    button[type="submit"]:hover { box-shadow: 0 0 30px rgba(0, 243, 255, 0.5) !important; }

    /* BACKGROUND ANIMASI */
    #rezzx-bg { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; pointer-events: none; }
    .bg-neutral-900 { background: transparent !important; }
</style>

<div id="rezzx-bg">
    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: radial-gradient(circle at center, transparent 20%, #050508 100%);"></div>
</div>
<header style="position: fixed; top: 0; width: 100%; padding: 15px 20px; display: flex; justify-content: space-between; z-index: 10;">
    <div style="font-family: 'Orbitron', sans-serif; font-size: 1.5rem; font-weight: 900; color: #fff; text-shadow: 0 0 10px #bc13fe;">
        <i class="fas fa-cube" style="color: #bc13fe;"></i> REZZX<span style="color: #00f3ff;">VIP</span>
    </div>
</header>
<footer style="position: fixed; bottom: 0; width: 100%; padding: 15px; text-align: center; font-family: 'Fira Code', monospace; font-size: 0.65rem; color: #555; background: #020202; z-index: 10;">
    &copy; 2026 Pterodactyl Software. Modified by <span style="color: #bc13fe;">REZZX VVIP</span>.
</footer>
<script>
    // Injeksi Logo VVIP ke dalam Form
    setInterval(() => {
        const form = document.querySelector('form');
        if(form && !document.getElementById('rezzx-form-header')) {
            const header = document.createElement('div');
            header.id = 'rezzx-form-header';
            header.innerHTML = '<img src="https://image2url.com/r2/default/images/1771473315834-818db508-f842-4c3c-9df8-02737412d92c.webp" style="width:70px; display:block; margin:0 auto 10px auto;"><h1 style="font-family:Orbitron; text-align:center; font-size:1.4rem;">SERVER PANEL</h1>';
            form.insertBefore(header, form.firstChild);
            
            const btn = form.querySelector('button[type="submit"]');
            if(btn) btn.innerText = "INITIATE LOGIN";
        }
    }, 100);
</script>
`;

// 2. MEMASUKKAN KODE KE WRAPPER PTERODACTYL
try {
    let wrapperContent = fs.readFileSync(wrapperPath, 'utf8');
    
    // Cegah duplikasi jika diinstall 2 kali
    if (!wrapperContent.includes('REZZX VVIP ENGINE')) {
        wrapperContent = wrapperContent.replace('</body>', `${vvipCode}\n</body>`);
        fs.writeFileSync(wrapperPath, wrapperContent);
        console.log("[RezzX Engine] HTML & CSS VVIP berhasil disuntikkan!");
    } else {
        console.log("[RezzX Engine] Tema VVIP sudah terpasang.");
    }
} catch (err) {
    console.error("[RezzX Engine] Error memodifikasi file Pterodactyl:", err);
}
