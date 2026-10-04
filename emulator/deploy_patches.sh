#!/usr/bin/env bash
# DIJALANKAN DI DALAM CONTAINER (root).
# Tanam file patch ke dalam image.raw (partisi ext2 mulai offset 1 MiB).
set -e
FA=/work/FirmAE
REPO=/repo
IMG="$FA/scratch/1/image.raw"
MNT=/tmp/imgpatch

for f in patches/httpd_rce patches/cfm_mib_dgram patches/libCfm_original.so patches/rc.g patches/console_elf; do
    [ -f "$REPO/$f" ] || { echo "[!] hilang: $REPO/$f"; exit 1; }
done

umount "$MNT" 2>/dev/null || true
losetup -D 2>/dev/null || true
sleep 1

mkdir -p "$MNT"
mount -o loop,rw,offset=1048576 "$IMG" "$MNT"

cp "$REPO/patches/httpd_rce"          "$MNT/bin/httpd"
cp "$REPO/patches/cfm_mib_dgram"      "$MNT/cfm_mib"
cp "$REPO/patches/libCfm_original.so" "$MNT/lib/libCfm.so"
cp "$REPO/patches/rc.g"               "$MNT/rc.g"
cp "$REPO/patches/console_elf"        "$MNT/firmadyne/console"
chmod 755 "$MNT/bin/httpd" "$MNT/cfm_mib" "$MNT/rc.g" "$MNT/firmadyne/console"

echo "[*] md5:"
md5sum "$MNT/bin/httpd" "$MNT/cfm_mib" "$MNT/lib/libCfm.so" "$MNT/rc.g" "$MNT/firmadyne/console"

umount "$MNT"
echo "[+] Patch tertanam."
