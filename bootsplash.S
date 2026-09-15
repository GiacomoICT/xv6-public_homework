#include "mmu.h"
#include "asm.h"

.code16
.global start
start:

movb $0x0,  %al

get_cursor:

movb $0x03, %ah
movb $0,    %bh
#Output is in dh (row) and dl(col)
int $0x10
cmpb $0x0, %al
jg wait_for_input

splash:

movb $0x13, %ah
movb $0x01, %al
movb $0x4,    %bl
movw str_sz,  %cx
lea  msg, %bp
int $0x10

jmp get_cursor

wait_for_input:

movb $0x0, %ah
int $0x16
#Returns scancode in ah and ascii in al

 
movb $0x13, %ah
movb $0x01, %al
movb $0x0a,    %bl
movw str2_sz,  %cx
lea  [msg2], %bp
int $0x10

movb $0x0, %ah
int $0x16

switch_to_video:

movb $0x0,  %ah
movb $0x13, %al
int $0x10


# Change to 32-bit protected mode so we can run C code
# We are adding the PROTECTED MODE bit to the other control bits in cr0
cli
lgdt    gdtdesc
movl    %cr0, %eax
orl     $CR0_PE, %eax
movl    %eax, %cr0

ljmp    $(SEG_KCODE<<3), $start32
.code32  # Tell assembler to generate 32-bit code now.
start32:

movw    $(SEG_KDATA<<3), %ax    # Our data segment selector
movw    %ax, %ds                # -> DS: Data Segment
movw    %ax, %es                # -> ES: Extra Segment
movw    %ax, %ss                # -> SS: Stack Segment
movw    $0, %ax                 # Zero segments not ready for use
movw    %ax, %fs                # -> FS
movw    %ax, %gs                # -> GS


mov     $0x1000, %esp
call splashmain

loop:
    jmp loop

hello: .string "xv6 @ UIC rocks!\r\n"
msg: .string "Welcome to xv6@UIC. Press any key to continue\r\n"
msg2: .string "You clicked!\r\n"
str_sz: .int 47
str2_sz: .int 14


# Bootstrap GDT
.p2align 2                                # force 4 byte alignment
gdt:
  SEG_NULLASM                             # null seg
  SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   # code seg
  SEG_ASM(STA_W, 0x0, 0xffffffff)         # data seg

gdtdesc:
  .word   (gdtdesc - gdt - 1)             # sizeof(gdt) - 1
  .long   gdt                             # address gdt
