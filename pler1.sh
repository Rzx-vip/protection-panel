#!/bin/bash

CTRL_DIR="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes"
VIEW_FILE="/var/www/pterodactyl/resources/views/admin/node_protect.blade.php"

echo "🚑 MEMULAI PEMULIHAN (RESTORE)..."

# Restore NodeController
if [ -f "$CTRL_DIR/NodeController.php.bak_original" ]; then
    mv "$CTRL_DIR/NodeController.php.bak_original" "$CTRL_DIR/NodeController.php"
    echo "✅ NodeController berhasil dikembalikan ke aslinya."
else
    echo "❌ Backup NodeController tidak ditemukan!"
fi

# Restore NodeViewController
if [ -f "$CTRL_DIR/NodeViewController.php.bak_original" ]; then
    mv "$CTRL_DIR/NodeViewController.php.bak_original" "$CTRL_DIR/NodeViewController.php"
    echo "✅ NodeViewController berhasil dikembalikan ke aslinya."
else
    echo "❌ Backup NodeViewController tidak ditemukan!"
fi

# Hapus file view sampah
if [ -f "$VIEW_FILE" ]; then
    rm "$VIEW_FILE"
    echo "🗑️  File tampilan protect dihapus."
fi

echo "✨ Panel Pterodactyl sudah kembali normal seperti semula."
