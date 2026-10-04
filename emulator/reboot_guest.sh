#!/usr/bin/env bash
# Reboot guest emulator (DI HOST). Container default: firmae-run.
set -e
NAME="${FIRMAE_CONTAINER:-firmae-run}"
FA=/work/FirmAE

if ! docker ps --format '{{.Names}}' | grep -qx "$NAME"; then
    echo "[*] Container '$NAME' belum jalan -> menjalankan..."
    "$(cd "$(dirname "$0")/.." && pwd)/docker/run-firmae.sh"
fi

echo "[*] Matikan QEMU lama..."
docker exec "$NAME" pkill -9 -f 'qemu-system-mips[e]l' 2>/dev/null || true
sleep 2

echo "[*] Bersihkan log & socket..."
docker exec "$NAME" bash -lc "rm -f $FA/scratch/1/qemu.final.serial.log /tmp/qemu.1.S1 /tmp/qemu.1"

echo "[*] Boot QEMU..."
docker exec -d "$NAME" bash -lc "setsid sh /repo/emulator/start_qemu.sh >/tmp/qemu_boot.out 2>&1 </dev/null"

echo "[*] Menunggu httpd siap..."
for i in $(seq 1 40); do
    sleep 2
    code=$(curl -s -m 5 -o /dev/null -w '%{http_code}' http://172.17.0.2:8080/ 2>/dev/null || true)
    if [ "$code" = "302" ]; then echo "[+] httpd siap (302)."; exit 0; fi
done
echo "[!] httpd belum siap (kode='$code'). Cek: docker exec $NAME tail -30 $FA/scratch/1/qemu.final.serial.log"
exit 1
