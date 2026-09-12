.code16
.globl start
start:
movb $0x13, %ah  # type of function to execute (0x09 is print character)
movb $0x01, %al  # what is moved into %al ?
movb $0,    %bh  # function params
movb $9,    %bl  # function params
movb hello_size, %cl  # function params
lea [hello], %bp
movb $0,    %dl
movb $0x0A, %dh
int $0x10        # actual interrupt call



stop:
jmp stop

hello:
.string "Hello World!"

hello_size:
.int 12

.org 0x1fe
.word 0xAA55


