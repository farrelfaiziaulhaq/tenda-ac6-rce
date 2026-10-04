#!/usr/bin/env bash
# DIJALANKAN DI DALAM CONTAINER (firmae-run).
# Pakai: docker exec firmae-run bash /repo/emulator/setup_emulator.sh
set -e
FA=/work/FirmAE
REPO=/repo

if [ ! -f "$REPO/emulator/rootfs.tar.gz" ]; then
    echo "[!] $REPO/emulator/rootfs.tar.gz tidak ditemukan."; exit 1
fi

echo "[*] Siapkan rootfs untuk FirmAE (images/1.tar.gz)..."
mkdir -p "$FA/images"
cp "$REPO/emulator/rootfs.tar.gz" "$FA/images/1.tar.gz"

echo "[*] Hapus scratch/1 lalu makeImage..."
rm -rf "$FA/scratch/1"
cd "$FA"
bash "$FA/scripts/makeImage.sh" 1 mipsel

echo "[*] Tanam patch..."
bash "$REPO/emulator/deploy_patches.sh"

echo "[+] Selesai. Image: $FA/scratch/1/image.raw"
ls -l "$FA/scratch/1/image.raw"
