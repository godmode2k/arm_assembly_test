@ ARM assembly test code
@ Reference: ARM System Developer's Guide (2004)
@ - hjkim, 2024.05.xx



.section .data
@ load / Store
@ initalize
val_r0: .word 0x00000000
val_r1: .word 0x00009000
val_r2: .word 0x01010101
val_r3: .word 0x02020202
@ ---
val2_r0: .word 0x00009010
val2_r1: .word 0x00009014
val2_r2: .word 0x00009018
@ ---
val3_r0: .word 0x00009000
val3_r1: .word 0x00000009
val3_r2: .word 0x00000008
val3_r3: .word 0x00000007
@ ---
@ loadstore_copy_blocks
val_cpb_r9: .word 0x00009000       @ start of source data (32 bytes)
val_cpb_r0: .word 0x00000001
val_cpb_r1: .word 0x00000002
val_cpb_r2: .word 0x00000003
val_cpb_r3: .word 0x00000004
val_cpb_r4: .word 0x00000005
val_cpb_r5: .word 0x00000006
val_cpb_r6: .word 0x00000007
val_cpb_r7: .word 0x00000008       @ end of source data
val_cpb_r10: .word 0x00009036      @ start of destination data
val_cpb_tmp: .skip 32+4            @ copied block (32 bytes)
@ ---
val4_r0: .word 0x00009000
val4_r1: .word 0x00000007
val4_r4: .word 0x00000008
@ ---
@ swap instruction
val5_r0: .word 0x00000000
val5_r1: .word 0x11112222
val5_r2: .word 0x00009000

@ ---
buf: .skip 4



@ ----------------------------


.section .text
.code 32


@.global main
@.func main
@main:

.global _start
_start:


    @bl test
    @bl barrel_shifter_ops
    @bl cpsr
    @bl branch_subroutine

    @ Load / Store
    mov r0, #0x00000000
    mov r1, #0x00000005
    bl loadstore
    bl loadstore_address_indexing
    bl loadstore_multiple_register_transfer
    bl loadstore_copy_blocks

    @ Stack
    //bl stack_ops
    //bl stack_overflow

    @ Swap instruction
    //bl swap_instruction

    @ SWI instruction
    //

    @ PSR instructions
    bl psr_instructions


@ ----------------------------


test:
    mov r0, #0x00000000
    mov r1, #0x00000005
    mov r2, #0x00000002
    mul r0, r1, r2

    mov r0, #0x00000000 @ RdLo
    mov r1, #0x00000000 @ RdHi
    mov r2, #0xf0000002
    mov r3, #0x00000002
    umull r0, r1, r2, r3

    bx lr


@ ----------------------------


barrel_shifter_ops:
@ Barrel shifter operation {
    mov r0, #0x00000000
    mov r1, #0x00000005
    mov r0, r1, LSL #2

    @ CPSR: C flag is updated
    mov r0, #0x00000000
    mov r1, #0x00000005
    movs r0, r1, LSL #1

    @ arithmetic instructions
    mov r0, #0x00000000
    mov r1, #0x00000005
    add r0, r1, r1, LSL #1
@ Barrel shifter }

    bx lr


@ ----------------------------


@ ----------------------------


@ CPSR {
cpsr:
    mov r1, #0x00000001
    subs r1, r1, #1
    svc #0

    mov r2, #0x00000002
    subs r1, r2, LSR #1

    mov r0, #0x00000000
    movs r0, r1, LSL #1
@ CPSR }

    bx lr


@ ----------------------------


@ Branch
@branch_subroutine:
@    mov r0, #0
@    mov pc, lr
@    @bx lr


@ ----------------------------


@ Load / Store

loadstore:
    @ Single-Register Transfer
    mov r0, #0x00000000
    ldr r1, addr_r1

    ldr r0, [r1] @ ldr r0, [r1, #0]

    mov r0, #0x00000000
    str r0, [r1] @ str r0, [r1, #0]

    bx lr


loadstore_address_indexing:
@ Address Indexing {
    mov r0, #0x00000000
    @ mov r1, #0x00009000
    str r0, [r1]

    ldr r2, addr_r2 @ 0x01010101
    ldr r3, addr_r3 @ 0x02020202

    @ Initialize data
    @ mem32[0x00009000] = 0x01010101
    @ mem32[0x00009004] = 0x02020202
    str r2, [r1]
    str r2, [r1, #4]

    @ -----

    @ Auto index
    @ Expected results
    @  -> r0 = 0x02020202
    @  -> r1 = 0x00009004
    ldr r0, [r1, #4]!

    @ Pre-index
    @ Expected results
    @  -> r0 = 0x02020202
    @  -> r1 = 0x00009000
    ldr r0, [r1, #4]

    @ Post-index
    @ Expected results
    @  -> r0 = 0x01010101
    @  -> r1 = 0x00009004
    ldr r0, [r1], #4
@ Address Indexing }

    bx lr


loadstore_multiple_register_transfer:
    @ Multiple-Register Transfer

    @ Load multiple
    mov r0, #0x00000000
    mov r1, #0x00000000
    mov r2, #0x00000000
    mov r3, #0x00000000
    ldr r0, addr2_r0
    ldr r4, addr2_r0
    ldr r5, addr2_r1
    ldr r6, addr2_r2
    mov r7, #0x01
    str r7, [r4]
    mov r7, #0x02
    str r7, [r5]
    mov r7, #0x03
    str r7, [r6]
    ldmia r0!, {r1-r3}

    mov r0, #0x00000000
    mov r1, #0x00000000
    mov r2, #0x00000000
    mov r3, #0x00000000
    mov r4, #0x00000000
    mov r5, #0x00000000
    mov r6, #0x00000000
    mov r7, #0x00000000


    @ LDM-STM fairs when base updated used.
    @STMIA   LDMDB
    @STMIB   LDMDA
    @STMDA   LDMIB
    @STMDB   LDMIA


    @ Store multiple
    ldr r0, addr3_r0
    ldr r1, addr3_r1
    ldr r2, addr3_r2
    ldr r3, addr3_r3
    stmib r0!, {r1-r3}
    mov r1, #1
    mov r2, #2
    mov r3, #3
    ldmda r0!, {r1-r3}

    mov r0, #0x00000000
    mov r1, #0x00000000
    mov r2, #0x00000000
    mov r3, #0x00000000
    mov r4, #0x00000000
    mov r5, #0x00000000
    mov r6, #0x00000000
    mov r7, #0x00000000
    mov r8, #0x00000000
    mov r9, #0x00000000
    mov r10, #0x00000000
    mov r11, #0x00000000

    bx lr

///*
loadstore_copy_blocks:
    @ Copies blocks of 32 bytes
    @ r9: start of source data
    @ r10: start of destination data
    @ r11: end of source data
    ldr r9, addr_cpb_r9
    ldr r0, addr_cpb_r0
    ldr r1, addr_cpb_r1
    ldr r2, addr_cpb_r2
    ldr r3, addr_cpb_r3
    ldr r4, addr_cpb_r4
    ldr r5, addr_cpb_r5
    ldr r6, addr_cpb_r6
    ldr r7, addr_cpb_r7
    ldr r11, addr_cpb_r11
    ldr r10, addr_cpb_r10
loadstore_copy_blocks_loop:
    ldmia r9!, {r0-r7}
    stmia r10!, {r0-r7}
    cmp r9, r11
    bne loadstore_copy_blocks_loop


    mov r0, #0x00000000
    mov r1, #0x00000000
    mov r2, #0x00000000
    mov r3, #0x00000000
    mov r4, #0x00000000
    mov r5, #0x00000000
    mov r6, #0x00000000
    mov r7, #0x00000000
    mov r8, #0x00000000
    mov r9, #0x00000000
    mov r10, #0x00000000
    mov r11, #0x00000000

    bx lr
//*/


@ ----------------------------


@ ------------------------------------------------------
@     Desc                Pop     = LDM   Push    = STM
@ ------------------------------------------------------
@ FA  full ascending      LDMFA   LDMDA   STMFA   STMIB
@ FD  full descending     LDMFD   LDMIA   STMFD   STMDB
@ EA  empty ascending     LDMEA   LDMDB   STMEA   STMIA
@ ED  empty descending    LDMED   LDMIB   STMED   STMDA
@ ------------------------------------------------------
@ Stack Operations {
stack_ops:
    mov r0, #0x00000000
    mov r1, #0x00000000
    mov r4, #0x00000000
    ldr r0, addr4_r0
    ldr r1, addr4_r1
    ldr r4, addr4_r4
    stmfd sp!, {r1, r4}

    @ Higher memory
    @ 0x00009000 (pre: <- sp)
    @ sp+4 -> r4
    @ sp+0 -> r1 (post: <- sp)
    @ Lower memory

    mov r0, #0x00000000
    mov r1, #0x00000000
    mov r4, #0x00000000

    @ ----------

    ldr r0, addr4_r0
    ldr r1, addr4_r1
    ldr r4, addr4_r4
    stmed sp!, {r1, r4}

    @ Higher memory
    @ 0x00009000 (pre: <- sp)
    @ sp+8 -> r4
    @ sp+4 -> r1
    @ sp+0 -> empty (post: <- sp)
    @ Lower memory

    mov r0, #0x00000000
    mov r1, #0x00000000
    mov r4, #0x00000000
@ Stack Operations }

    bx lr


/*
@ Stack Overflow {
stack_overflow:
    sub sp, sp, #size
    cmp sp, r10
    bllo err_stack_overflow

    bx lr

err_stack_overflow:
    mov r0, #0x0000AAAA
    bx lr
err_stack_underflow:
    mov r0, #0x0000BBBB
    bx lr
@ Stack Overflow }
*/


//push {r11, lr}
//add r11, sp, #4 // base pointer
//pop {r11, pc}
//
//.data string:  .asciz "result: %p, %p"
//var1: .word 1, 2, 3
//var2: .word 0, 1, 0
//.text .extern printf
//push {lr}
//ldr r0, =string
//ldr r1, =var1
//ldr r2, =var2
//bl printf
//pop {lr}
//
//str r3, [sp, #-4]!  @ push {r3}
//ldr r3, [sp], #4    @ pop {r3}
//
// push/pop: only r13
//push == stmdb r13!
//pop  == ldmia r13!



@ Swap instruction
swap_instruction:
    mov r0, #0x00000000
    mov r1, #0x00000000
    mov r2, #0x00000000
    mov r3, #0x00000000
 
    ldr r0, addr5_r0
    ldr r1, addr5_r1
    ldr r2, addr5_r2
    mov r3, #0x4141
    str r3, [r2]
    swp r0, r1, [r2]

    mov r0, #0x00000000
    mov r1, #0x00000000
    mov r2, #0x00000000
    mov r3, #0x00000000
 
    bx lr


@ SWI instruction



@ PSR instructions
psr_instructions:
    mrs r1, cpsr
    bic r1, r1, #0x80 @ 0b01000000
    msr cpsr_c, r1

    bx lr



@ ----------------------------


@ exit {
    mov pc, lr

    @ or
    @mov r7, #1      @ exit system call (without 0x900000 prefix)
    @mov r0, #0      @ error code: no error
    @svc 0
@ exit }


@ ----------------------------


@val_r0: .word 0x00000000
@val_r1: .word 0x00009000
@val_r2: .word 0x01010101
@val_r3: .word 0x02020202
addr_r0: .word val_r0
addr_r1: .word val_r1
addr_r2: .word val_r2
addr_r3: .word val_r3

@val2_r0: .word 0x00009010
@val2_r1: .word 0x00009014
@val2_r2: .word 0x00009018
addr2_r0: .word val2_r0
addr2_r1: .word val2_r1
addr2_r2: .word val2_r2

@val3_r0: .word 0x00009000
@val3_r1: .word 0x00000009
@val3_r2: .word 0x00000008
@val3_r3: .word 0x00000007
addr3_r0: .word val3_r0
addr3_r1: .word val3_r1
addr3_r2: .word val3_r2
addr3_r3: .word val3_r3

@ loadstore_copy_blocks
@val_cpb_r9: .word 0x00009000      @ start of source data (32 bytes)
@val_cpb_r0: .word 0x00000001
@val_cpb_r1: .word 0x00000002
@val_cpb_r2: .word 0x00000003
@val_cpb_r3: .word 0x00000004
@val_cpb_r4: .word 0x00000005
@val_cpb_r5: .word 0x00000006
@val_cpb_r6: .word 0x00000007
@val_cpb_r7: .word 0x00000008      @ end of source data
@val_cpb_r10: .word 0x00009036     @ start of destination data
@val_cpb_tmp: .skip 32+4            @ copied block
addr_cpb_r9: .word val_cpb_r9     @ start of source data (32 bytes)
addr_cpb_r0: .word val_cpb_r0
addr_cpb_r1: .word val_cpb_r1
addr_cpb_r2: .word val_cpb_r2
addr_cpb_r3: .word val_cpb_r3
addr_cpb_r4: .word val_cpb_r4
addr_cpb_r5: .word val_cpb_r5
addr_cpb_r6: .word val_cpb_r6
addr_cpb_r7: .word val_cpb_r7
addr_cpb_r11: .word val_cpb_r7    @ end of source data
addr_cpb_r10: .word val_cpb_r10   @ start of destination data

@val4_r0: .word 0x00009000
@val4_r1: .word 0x00000007
@val4_r4: .word 0x00000008
addr4_r0: .word val4_r0
addr4_r1: .word val4_r1
addr4_r4: .word val4_r4

@ swap instruction
@val5_r0: .word 0x00000000
@val5_r1: .word 0x11112222
@val5_r2: .word 0x00009000
addr5_r0: .word val5_r0
addr5_r1: .word val5_r1
addr5_r2: .word val5_r2



@ ----------------------------
@ _EOF_
