    .set noreorder
    .text
    .globl _cave
_cave:
    lw   $t0, 892($s8)
    lui  $t1, 0x50
    ori  $t1, $t1, 0x47c0
    bne  $t0, $t1, norm
    nop
    lui  $a0, 0x50
    ori  $a0, $a0, 0xb450
    lui  $t9, 0x50
    ori  $t9, $t9, 0x47c0
    lui  $ra, 0x47
    ori  $ra, $ra, 0x7de4
    jr   $t9
    nop
norm:
    lw   $gp, 24($s8)
    lw   $a0, 896($s8)
    j    0x477de4
    nop
