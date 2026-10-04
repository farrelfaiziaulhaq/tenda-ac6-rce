#!/bin/sh
# Start QEMU guest (DI DALAM container). Isolasi: user-net + hostfwd, tanpa rute ke LAN asli.
exec qemu-system-mipsel -m 256 -M malta \
 -kernel /work/FirmAE/binaries/vmlinux.mipsel.4 \
 -drive if=ide,format=raw,file=/work/FirmAE/scratch/1/image.raw \
 -append "firmadyne.syscall=1 root=/dev/sda1 console=ttyS0 nandsim.parts=64,64,64,64,64,64,64,64,64,64 init=/firmadyne/console rw debug ignore_loglevel print-fatal-signals=1 FIRMAE_NET=true FIRMAE_NVRAM=true FIRMAE_KERNEL=true FIRMAE_ETC=true user_debug=31" \
 -serial file:/work/FirmAE/scratch/1/qemu.final.serial.log \
 -serial unix:/tmp/qemu.1.S1,server,nowait \
 -monitor unix:/tmp/qemu.1,server,nowait \
 -display none \
 -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::8080-:80,hostfwd=tcp::8081-:23,hostfwd=tcp::2323-:2323 \
 -device e1000,netdev=net1 -netdev user,id=net1 \
 -device e1000,netdev=net2 -netdev user,id=net2
