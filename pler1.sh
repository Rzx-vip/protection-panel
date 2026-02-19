#!/bin/bash

echo "🚑 MEMULAI PERBAIKAN TOTAL NODES PTERODACTYL..."

# Masuk ke direktori Pterodactyl
cd /var/www/pterodactyl || exit

echo "📥 Mendownload file original resmi dari Pterodactyl..."
# Kita download panel.tar.gz resmi terbaru
curl -L -s https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz -o panel_temp.tar.gz

echo "📦 Mengekstrak file NodeController dan NodeViewController original..."
# Kita hanya mengekstrak 2 file controller yang bermasalah agar kembali seperti bawaan pabrik
tar -xzvf panel_temp.tar.gz app/Http/Controllers/Admin/Nodes/NodeController.php
tar -xzvf panel_temp.tar.gz app/Http/Controllers/Admin/Nodes/NodeViewController.php

echo "🗑️ Membersihkan sisa file protect dan file sementara..."
rm -f panel_temp.tar.gz
rm -f resources/views/admin/node_protect.blade.php

echo "🔧 Mengatur ulang perizinan file (Permissions)..."
chown -R www-data:www-data app/Http/Controllers/Admin/Nodes
chmod 644 app/Http/Controllers/Admin/Nodes/NodeController.php
chmod 644 app/Http/Controllers/Admin/Nodes/NodeViewController.php

echo "🧹 Membersihkan Cache Pterodactyl (Sangat penting untuk menghilangkan Error 500)..."
php artisan view:clear
php artisan cache:clear
php artisan route:clear
php artisan config:clear
php artisan optimize:clear

echo "✅ SELESAI! Panel sudah kembali 100% Original bawaan pabrik."
