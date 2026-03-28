.section .init
//set irq table
la x3,trap_table
csrrw   x0,mtvec,x3

//open irq
li t0, 0x80
csrs mstatus, t0

//close ext irq
li t1,0x0
csrrw   x0,mie,t1

//enable debug_monitor
la x2,0x1
csrrw x0,dcsr,x2

li t1,0x2
csrrw   x0,mie,t1
//enter usermode
la x1,main_loop
csrrw x0,mepc,x1
mret
//lr.w x4,(x1)
// sc.w x5,x3,(x1)
main_loop:

addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0

ebreak
addi x0,x0,5
addi x0,x0,6
addi x1,x2,5
1:
addi x5,x1,2
la x1,jile
//j 1b
mret
j 1b
.balign 256
trap_table:
    j   .   //mem fault
    j   debug_irq
    j   ext_int
    j   .
    j   .
    mret//j   .//timer fault
    j   .
ext_int:
    addi x0,x0,0
    addi x0,x0,0
    mret
debug_irq:
    li x15,0
    li x16,2
    li x17,3
    li x18,4
    la x8,0x01000000
    lw x10,0(x8)
    bne x10,x15,1f
        sw x16,0(x8)
        la x20,0xc1
        csrrw x0,dcsr,x20
        j end
    1:
    bne x10,x16,1f
        sw x17,0(x8)
        la x20,0xc1
        csrrw x0,dcsr,x20
        j end
    1:
    la x20,0x01
    csrrw x0,dcsr,x20
    end:
    csrrw x7,mepc,x0
    addi x7,x7,4
    csrrw x0,mepc,x7
    dret
jile:
    j .
