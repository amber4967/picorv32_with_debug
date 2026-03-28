.section .init
la x3,trap_table
csrrw   x0,mtvec,x3
li t0, 0x8
csrs mstatus, t0
li t1,0x0
csrrw   x0,mie,t1
csrci mstatus, 8
la x1,0x02000000
la x2,2
la x3,3
la x1,main_loop
csrrw x0,mepc,x1
mret
//lr.w x4,(x1)
// sc.w x5,x3,(x1)
main_loop:
addi x0,x0,5
addi x0,x0,6
addi x1,x2,5
mul x2,x1,x3
addi x5,x1,0
la x1,jile
mret
j main_loop
.balign 256
trap_table:
    j   .   //mem fault
    j   .
    j   ext_int
    j   .
    j   .
    mret//j   .//timer fault
    j   .
ext_int:
    addi x0,x0,0
    addi x0,x0,0
    mret

jile:
    j .
