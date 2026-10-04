#!/usr/bin/env bash
# Bootstrap: dependency + FirmAE (binaries) + image docker (fcore) + container.
set -e
REPO="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Repo: $REPO"

echo "[*] 1/4 Dependency sistem (apt)..."
sudo apt update
sudo apt install -y docker.io python3 python3-pip qemu-user qemu-system-mips \
                    binutils-mipsel-linux-gnu nmap netcat-openbsd unzip wget
sudo usermod -aG docker "$USER" 2>/dev/null || true

echo "[*] 2/4 Dependency python (pwntools)..."
pip3 install --user --break-system-packages pwntools || true

echo "[*] 3/4 FirmAE binaries (kernel/busybox/console/gdb)..."
if [ ! -f "$REPO/FirmAE/binaries/vmlinux.mipsel.4" ]; then
    ( cd "$REPO/FirmAE" && ./download.sh )
else
    echo "    binaries sudah ada, dilewati."
fi

echo "[*] 4/4 Image docker 'fcore' + container..."
if ! docker image inspect fcore >/dev/null 2>&1; then
    ( cd "$REPO/FirmAE" && sudo ./docker-init.sh )
fi
"$REPO/docker/run-firmae.sh"

echo
echo "[+] Bootstrap selesai. Langkah berikutnya:"
echo "    docker exec firmae-run bash /repo/emulator/setup_emulator.sh"
echo "    $REPO/emulator/reboot_guest.sh"
echo "    python3 $REPO/exploit/exploit.py"
