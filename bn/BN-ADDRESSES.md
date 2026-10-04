# Binary Ninja — alamat & fungsi kunci

Buka `firmware/httpd` → tunggu analisis → view **High Level IL**.
Navigasi: klik panel tengah → tekan **`g`** → ketik alamat → Enter (atau cari di panel Symbols).

| Fungsi / item | Alamat | Peran |
|---|---|---|
| `getwebuserpwd` | `0x434694` | BACKDOOR: baca `sys.baseusername` & `sys.baseuserpass` (default `user`/`user`) |
| `check_password` | `0x437fc0` | bandingkan password dgn `sys.userpass` |
| `R7WebsSecurityHandler` | `0x434c50` | handler keamanan halaman |
| `form_fast_setting_wifi_set` | `0x477c20` | OVERFLOW: dua `strcpy(dest, ssid)` tanpa cek panjang |
| `system()` | `0x005047c0` | target saved `$ra` |
| `doSystemCmd()` | `0x00505380` | alternatif |
| `execve()` | `0x00504400` | alternatif |
| `strcpy()` | `0x00504820` | fungsi rentan |
| offset saved `$ra` | `748` | dari buffer kedua (`fp+0x90`) ke `fp+892` |
| string `sys.baseusername` | `0x507df4` | dipakai `getwebuserpwd` |
| string `sys.baseuserpass` | `0x507e08` | dipakai `getwebuserpwd` |
| string `sys.userpass` | `0x507de4` | dipakai `check_password` |
| string `/login/Auth` | `0x507738` | endpoint login |

## Plugin (opsional)
`bn/reportdecomp.py` — navigasi otomatis ke fungsi target saat binary dibuka.
Salin ke `~/.binaryninja/plugins/`, atur target lewat file `/tmp/bn_nav_addr` (hex).

## Lihat config (contoh)
```bash
grep -a -E "sys\.(baseusername|baseuserpass)=" firmware/mib.sample.cfg
```
