#!/bin/bash
# Nama file di GitHub: build.sh

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN}      REZZX VVIP THEME - OFFICIAL COMPILER            ${NC}"
echo -e "${CYAN}======================================================${NC}"

PTERO_DIR="/var/www/pterodactyl"

cd $PTERO_DIR

# 1. Download Script Node.js Installer dari Github kamu
# (NANTI GANTI URL INI DENGAN URL RAW GITHUB KAMU YANG ASLI)
echo -e "${GREEN}[+] Mendownload Engine Tema VVIP...${NC}"
curl -sL https://raw.githubusercontent.com/Rzx-vip/protection-panel/refs/heads/main/index.js -o index.js

# 2. Jalankan Script Installer
echo -e "${GREEN}[+] Menjalankan Proses Injeksi VVIP...${NC}"
node theme-installer.js

# 3. Proses Compile Pterodactyl Kelas Profesional (Butuh RAM besar, 64GB kamu pasti sanggup!)
echo -e "${CYAN}[~] Memulai proses Build React Pterodactyl (Ini memakan waktu beberapa menit)...${NC}"

# Menginstal dependensi yarn jika belum ada
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn -y

# Melakukan Build
yarn install
yarn build:production

# 4. Bersihkan Cache Pterodactyl
echo -e "${GREEN}[+] Membersihkan Cache...${NC}"
php artisan view:clear
php artisan config:clear
php artisan cache:clear

# Hapus file installer agar bersih
rm theme-installer.js

echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN} INSTALASI SELESAI! TEMA VVIP TELAH MENYATU DENGAN CORE! ${NC}"
echo -e "${CYAN}======================================================${NC}"
