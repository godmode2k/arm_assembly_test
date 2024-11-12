#!/bin/sh

AS_BIN=arm-none-linux-gnueabihf-as
LD_BIN=arm-none-linux-gnueabihf-ld

$AS_BIN -o test_arm_asm_aarch32.o test_arm_asm_aarch32.s -g
$LD_BIN -o test_arm_asm_aarch32.elf test_arm_asm_aarch32.o -g


