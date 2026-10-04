    .set noreorder
    .text
    .globl _start
_start:
    lui   $a0, %hi(path)
    addiu $a0, $a0, %lo(path)
    lui   $a1, %hi(argv)
    addiu $a1, $a1, %lo(argv)
    lui   $a2, %hi(envp)
    addiu $a2, $a2, %lo(envp)
    li    $v0, 4011
    syscall
fail:
    j     fail
    nop

    .data
argv:
    .word av0, av1, av2, 0
envp:
    .word env0, 0
av0:
    .asciz "/firmadyne/busybox"
av1:
    .asciz "sh"
av2:
    .asciz "/rc.g"
env0:
    .asciz "PATH=/sbin:/bin:/usr/sbin:/usr/bin"
path:
    .asciz "/firmadyne/busybox"
