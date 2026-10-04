    .set noreorder
    .text
    .globl _start
_start:
    li   $v0, 4183
    li   $a0, 1
    li   $a1, 2
    move $a2, $zero
    syscall
    move $s0, $v0
    li   $v0, 4010
    la   $a0, sockpath
    syscall
    li   $v0, 4169
    move $a0, $s0
    la   $a1, addr
    li   $a2, 110
    syscall
    la   $t0, clen
    li   $t1, 128
    sw   $t1, 0($t0)
loop:
    # recvfrom(s0, rbuf, 2016, 0, caddr, &clen)
    li   $v0, 4176
    move $a0, $s0
    la   $a1, rbuf
    li   $a2, 2016
    move $a3, $zero
    addiu $sp, $sp, -32
    la   $t0, caddr
    sw   $t0, 16($sp)
    la   $t0, clen
    sw   $t0, 20($sp)
    syscall
    addiu $sp, $sp, 32
    blez $v0, loop
    nop
    # zero wbuf
    la   $t0, wbuf
    li   $t1, 504
zloop:
    sw   $zero, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    bnez $t1, zloop
    nop
    # op+1
    la   $t0, rbuf
    lw   $t0, 0($t0)
    addiu $t0, $t0, 1
    la   $t1, wbuf
    sw   $t0, 0($t1)
    # copy key
    la   $t0, rbuf
    addiu $t0, $t0, 4
    la   $t1, wbuf
    addiu $t1, $t1, 4
    li   $t2, 512
kloop:
    lbu  $t3, 0($t0)
    sb   $t3, 0($t1)
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    addiu $t2, $t2, -1
    bnez $t2, kloop
    nop
    # if op==2, lookup MIB
    la   $t0, rbuf
    lw   $t0, 0($t0)
    li   $t1, 2
    bne  $t0, $t1, dosend
    nop
    jal  mib_lookup
    nop
dosend:
    # sendto(s0, wbuf, 2016, 0, caddr, clen)
    li   $v0, 4180
    move $a0, $s0
    la   $a1, wbuf
    li   $a2, 2016
    move $a3, $zero
    addiu $sp, $sp, -32
    la   $t0, caddr
    sw   $t0, 16($sp)
    la   $t0, clen
    lw   $t1, 0($t0)
    sw   $t1, 20($sp)
    syscall
    addiu $sp, $sp, 32
    j    loop
    nop
# lookup key at rbuf+4 in embedded mib; copy value to wbuf+516 (max 32)
mib_lookup:
    addiu $sp, $sp, -32
    sw   $ra, 28($sp)
    sw   $s2, 24($sp)
    sw   $s3, 20($sp)
    la   $s2, mib_start
    la   $s3, mib_end
    la   $t4, rbuf
    addiu $t4, $t4, 4
    move $t0, $s2
    move $t1, $t4
    jal  match_line
    nop
    bnez $v0, found
    nop
scan:
    lbu  $t5, 0($s2)
    beqz $t5, notfound
    nop
    li   $t6, 10
    beq  $t5, $t6, atline
    nop
    addiu $s2, $s2, 1
    slt  $t7, $s2, $s3
    bnez $t7, scan
    nop
    b    notfound
    nop
atline:
    addiu $s2, $s2, 1
    slt  $t7, $s2, $s3
    beqz $t7, notfound
    nop
    move $t0, $s2
    move $t1, $t4
    jal  match_line
    nop
    bnez $v0, found
    nop
    move $s2, $t0
    j    scan
    nop
found:
    addiu $t0, $t0, 1
    la   $t1, wbuf
    addiu $t1, $t1, 516
    li   $t2, 32
cpy:
    beqz $t2, lend
    nop
    lbu  $t3, 0($t0)
    beqz $t3, lend
    nop
    li   $t5, 10
    beq  $t3, $t5, lend
    nop
    sb   $t3, 0($t1)
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    addiu $t2, $t2, -1
    b    cpy
    nop
lend:
    sb   $zero, 0($t1)
notfound:
    lw   $ra, 28($sp)
    lw   $s2, 24($sp)
    lw   $s3, 20($sp)
    addiu $sp, $sp, 32
    jr   $ra
    nop
# match_line: t0=line ptr, t1=key ptr. v0=1 if line starts "key="
match_line:
    lbu  $t2, 0($t1)
    beqz $t2, m_eq
    nop
    lbu  $t3, 0($t0)
    bne  $t2, $t3, m_no
    nop
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    b    match_line
    nop
m_eq:
    lbu  $t3, 0($t0)
    li   $t4, 61
    beq  $t3, $t4, m_yes
    nop
m_no:
    li   $v0, 0
    jr   $ra
    nop
m_yes:
    li   $v0, 1
    jr   $ra
    nop
    .data
    .align 2
addr:
    .short 1
    .asciz "/var/cfm_socket"
    .space 90
sockpath:
    .asciz "/var/cfm_socket"
caddr:
    .space 128
    .align 2
clen:
    .word 128
    .section .rodata
    .align 2
mib_start:
    .incbin "mib_embed.cfg"
mib_end:
    .byte 0
    .bss
    .align 2
rbuf:
    .space 2016
wbuf:
    .space 2016
