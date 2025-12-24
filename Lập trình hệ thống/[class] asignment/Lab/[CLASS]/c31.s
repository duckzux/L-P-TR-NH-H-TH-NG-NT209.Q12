.section .data
inp:   .string "Enter a number (5-digit):"
giam:  .string "Giam dan"
tang:  .string "Khong giam dan"
loi:  .string "So khong hop le"
.section .bss
    .lcomm out, 8
.section .text
    .globl _start
_start:
    movl $4, %eax
    movl $1, %ebx
    movl $inp, %ecx
    movl $26, %edx
    int  $0x80
    movl $3, %eax
    movl $0, %ebx
    movl $out, %ecx
    movl $8, %edx
    int  $0x80
    movl %eax, %esi
    cmpl $6, %esi
    jne khople
    movl $out, %eax
    movl $0, %edi

chuso:
    movb (%eax,%edi,1), %bl
    cmpb $'\n', %bl
    je   xong
    cmpb $'0', %bl
    jl   khople
    cmpb $'9', %bl
    jg   khople
    incl %edi
    cmpl $5, %edi
    jl   chuso

xong:
    movl $out, %eax
    movb 0(%eax), %bl
    movb 1(%eax), %bh
    cmpb %bh, %bl
    jle  kgiam
    movb 1(%eax), %bl
    movb 2(%eax), %bh
    cmpb %bh, %bl
    jle  kgiam
    movb 2(%eax), %bl
    movb 3(%eax), %bh
    cmpb %bh, %bl
    jle  kgiam
    movb 3(%eax), %bl
    movb 4(%eax), %bh
    cmpb %bh, %bl
    jle  kgiam

giamdan:
    movl $4, %eax
    movl $1, %ebx
    movl $giam, %ecx
    movl $10, %edx
    int  $0x80
    jmp  exit

kgiam:
    movl $4, %eax
    movl $1, %ebx
    movl $tang, %ecx
    movl $15, %edx
    int  $0x80
    jmp  exit

khople:
    movl $4, %eax
    movl $1, %ebx
    movl $loi, %ecx
    movl $17, %edx
    int  $0x80

exit:
    movl $1, %eax
    int  $0x80
