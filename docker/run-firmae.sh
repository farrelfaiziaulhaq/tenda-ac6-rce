#!/usr/bin/env bash
# Jalankan container FirmAE (image fcore) dengan mount /dev + FirmAE + repo.
# Nama container: firmae-run (dipakai script lain).
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${FIRMAE_CONTAINER:-firmae-run}"

if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
    echo "[*] Container '$NAME' sudah ada. Menjalankan..."
    docker start "$NAME" >/dev/null
else
    echo "[*] Membuat container '$NAME'..."
    docker run -dit --name "$NAME" --privileged \
        -v /dev:/dev \
        -v "$REPO/FirmAE":/work/FirmAE \
        -v "$REPO":/repo \
        fcore bash -lc 'sleep infinity'
fi

echo "[+] Container '$NAME' siap."
echo "    FirmAE : /work/FirmAE  (host: $REPO/FirmAE)"
echo "    Repo   : /repo         (host: $REPO)"
