.section .data
    inp1: .string "Enter number 1st (1-digit): "
    len1 = . - inp1
    inp2: .string "Enter number 2nd (1-digit): "
    len2 = . - inp2
    inp3: .string "Enter number 3rd (1-digit): "
    len3 = . - inp3
    inp4: .string "Enter number 4th (1-digit): "
    len4 = . - inp4
    inp5: .string "Enter number 5th (1-digit): "
    len5 = . - inp5

    out: .string "Count (>=5): "
    out_len = . - out

    newline: .string "\n"
    n_len = . - newline

.section .bss
    .lcomm num, 2
    .lcomm count, 4
    .lcomm chiso, 4

.section .text
    .globl _start
_start:
    movl $0, count
    movl $0, chiso

loop:
    cmpl $5, chiso
    je end
    movl $4, %eax
    movl $1, %ebx
    cmpl $0, chiso
    je inp_1
    cmpl $1, chiso
    je inp_2
    cmpl $2, chiso
    je inp_3
    cmpl $3, chiso
    je inp_4
    jmp inp_5

inp_1:
    movl $inp1, %ecx
    movl $len1, %edx
    jmp xuat
inp_2:
    movl $inp2, %ecx
    movl $len2, %edx
    jmp xuat
inp_3:
    movl $inp3, %ecx
    movl $len3, %edx
    jmp xuat
inp_4:
    movl $inp4, %ecx
    movl $len4, %edx
    jmp xuat
inp_5:
    movl $inp5, %ecx
    movl $len5, %edx

xuat:
    int $0x80
    movl $3, %eax
    movl $0, %ebx
    movl $num, %ecx
    movl $2, %edx
    int $0x80
    movzbl num, %eax
    sub $0x30, %eax
    cmpl $5, %eax
    jl skip
    incl count

skip:
    incl chiso
    jmp loop

end:
    movl $4, %eax
    movl $1, %ebx
    movl $out, %ecx
    movl $out_len, %edx
    int $0x80
    movl count, %eax
    add $0x30, %eax
    movl %eax, num
    movl $4, %eax
    movl $1, %ebx
    movl $num, %ecx
    movl $1, %edx
    int $0x80
    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $n_len, %edx
    int $0x80

    movl $1, %eax
    int $0x80
