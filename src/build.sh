#!/usr/bin/env bash
# Bangun binary dari sumber asm. Butuh: binutils-mipsel-linux-gnu.
set -e
AS=mipsel-linux-gnu-as
LD=mipsel-linux-gnu-ld
HERE="$(cd "$(dirname "$0")" && pwd)"

build() {
    n="$1"; entry="$2"
    "$AS" -mips32 -EL -o "/tmp/$n.o" "$HERE/$n.s"
    "$LD" -e "$entry" -o "$HERE/$n" "/tmp/$n.o"
    echo "built: $HERE/$n"
}

build cave_final      _cave     # kode gua (set $a0=cmd, t9=system)
build cfm_mib_dgram   _start    # server CFM (DGRAM)
build console_elf     _start    # init guest (exec busybox sh /rc.g)
