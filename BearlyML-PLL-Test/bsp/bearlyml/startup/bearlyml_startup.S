#include "encoding.h"

//#if __riscv_xlen == 64
  #define LREG ld
  #define SREG sd
  #define REGBYTES 8
/*#else
  #define LREG lw
  #define SREG sw
  #define REGBYTES 4
#endif
*/

/* start address for the .data section. defined in linker script */  
.word  _data_source_start
/* end address for the .data section. defined in linker script */
.word  _data_target_start
.word  _data_target_end
/* start address for the .bss section. defined in linker script */
.word  _bss_start
/* end address for the .bss section. defined in linker script */
.word  _bss_end

.align 4
.section .text.reset
j _start

.align 4
.section .text.isr_routine
.globl isr_routine
isr_routine:
  addi sp, sp, -32*REGBYTES

  SREG x1, 1*REGBYTES(sp)
  SREG x2, 2*REGBYTES(sp)
  SREG x3, 3*REGBYTES(sp)
  SREG x4, 4*REGBYTES(sp)
  SREG x5, 5*REGBYTES(sp)
  SREG x6, 6*REGBYTES(sp)
  SREG x7, 7*REGBYTES(sp)
  SREG x8, 8*REGBYTES(sp)
  SREG x9, 9*REGBYTES(sp)
  SREG x10, 10*REGBYTES(sp)
  SREG x11, 11*REGBYTES(sp)
  SREG x12, 12*REGBYTES(sp)
  SREG x13, 13*REGBYTES(sp)
  SREG x14, 14*REGBYTES(sp)
  SREG x15, 15*REGBYTES(sp)
  SREG x16, 16*REGBYTES(sp)
  SREG x17, 17*REGBYTES(sp)
  SREG x18, 18*REGBYTES(sp)
  SREG x19, 19*REGBYTES(sp)
  SREG x20, 20*REGBYTES(sp)
  SREG x21, 21*REGBYTES(sp)
  SREG x22, 22*REGBYTES(sp)
  SREG x23, 23*REGBYTES(sp)
  SREG x24, 24*REGBYTES(sp)
  SREG x25, 25*REGBYTES(sp)
  SREG x26, 26*REGBYTES(sp)
  SREG x27, 27*REGBYTES(sp)
  SREG x28, 28*REGBYTES(sp)
  SREG x29, 29*REGBYTES(sp)
  SREG x30, 30*REGBYTES(sp)
  SREG x31, 31*REGBYTES(sp)

  call trap_handler
  
  LREG x1, 1*REGBYTES(sp)
  LREG x2, 2*REGBYTES(sp)
  LREG x3, 3*REGBYTES(sp)
  LREG x4, 4*REGBYTES(sp)
  LREG x5, 5*REGBYTES(sp)
  LREG x6, 6*REGBYTES(sp)
  LREG x7, 7*REGBYTES(sp)
  LREG x8, 8*REGBYTES(sp)
  LREG x9, 9*REGBYTES(sp)
  LREG x10, 10*REGBYTES(sp)
  LREG x11, 11*REGBYTES(sp)
  LREG x12, 12*REGBYTES(sp)
  LREG x13, 13*REGBYTES(sp)
  LREG x14, 14*REGBYTES(sp)
  LREG x15, 15*REGBYTES(sp)
  LREG x16, 16*REGBYTES(sp)
  LREG x17, 17*REGBYTES(sp)
  LREG x18, 18*REGBYTES(sp)
  LREG x19, 19*REGBYTES(sp)
  LREG x20, 20*REGBYTES(sp)
  LREG x21, 21*REGBYTES(sp)
  LREG x22, 22*REGBYTES(sp)
  LREG x23, 23*REGBYTES(sp)
  LREG x24, 24*REGBYTES(sp)
  LREG x25, 25*REGBYTES(sp)
  LREG x26, 26*REGBYTES(sp)
  LREG x27, 27*REGBYTES(sp)
  LREG x28, 28*REGBYTES(sp)
  LREG x29, 29*REGBYTES(sp)
  LREG x30, 30*REGBYTES(sp)
  LREG x31, 31*REGBYTES(sp)

  addi sp, sp, 32*REGBYTES
  mret

.section .text.init
.globl _start
_start:
  # initialize registers
  li x1, 0
  li x2, 0
  li x3, 0
  li x4, 0
  li x5, 0
  li x6, 0
  li x7, 0
  li x8, 0
  li x9, 0
  li x10, 0
  li x11, 0
  li x12, 0
  li x13, 0
  li x14, 0
  li x15, 0
  li x16, 0
  li x17, 0
  li x18, 0
  li x19, 0
  li x20, 0
  li x21, 0
  li x22, 0
  li x23, 0
  li x24, 0
  li x25, 0
  li x26, 0
  li x27, 0
  li x28, 0
  li x29, 0
  li x30, 0
  li x31, 0

  # set up interrupt handler
  la t0, isr_routine
  csrw mtvec, t0

  # start set up C runtime

  # set up global pointer
.option push
.option norelax
  la gp, __global_pointer$
.option pop

  # only the boot hart need to execute section initialization
  csrr a0, mhartid
  li a1, 1

  li t0, 0    # hart 0 is the boot hart
  bne a0, t0, bss_init_exit

data_init_entry:
  la t0, _data_source_start
  la t1, _data_target_start
  la t2, _data_target_end

  # see if:
  # - data section is already at correct location?
  # - data section is of size 0?
  beq t0, t1, data_init_exit
  bge t1, t2, data_init_exit

data_init_loop:
#if __riscv_xlen == 32
  lw   t3, 0(t0)
  sw   t3, 0(t1)
  addi t0, t0, 4
  addi t1, t1, 4
  blt  t1, t2, data_init_loop
#else
  ld   t3, 0(t0)
  sd   t3, 0(t1)
  addi t0, t0, 8
  addi t1, t1, 8
  blt  t1, t2, data_init_loop
#endif
data_init_exit:


bss_init_entry:
/* Zero fill the bss segment. */
  la t0, _bss_start
  la t1, _bss_end

  # see if bss section is of size 0?
  beq t0, t1, bss_init_exit

bss_init_loop:
#if __riscv_xlen == 32
  lw zero, 0(t0)
  addi t0, t0, 4
  blt t0, t1, bss_init_loop
#else
  ld zero, 0(t0)
  addi t0, t0, 8
  blt t0, t1, bss_init_loop
#endif

bss_init_exit:


  # set up stack pointers
  la sp, _sp
  la tp, _sp

  call system_init
  call main

infinite_loop:
  j infinite_loop