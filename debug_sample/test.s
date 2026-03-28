.section .init
addi x1,x0,0
addi x2,x0,0
addi x3,x0,0
addi x7,x0,0
la a0,0x01000000
li a1,0xff
li a2,0

loop:
la a3,6553
1:
addi a3,a3,-1
bne a3,x0,1b
lw a4,(a0)
xor a4,a4,a1
sw a4,(a0)
j loop