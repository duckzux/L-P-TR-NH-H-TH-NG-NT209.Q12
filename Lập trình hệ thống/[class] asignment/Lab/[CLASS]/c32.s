.section .data
msg_in: .string "Enter a string (<256 chars): "
msg_out: .string "Chuoi chuan hoa: "

.section .bss
.lcomm input, 256
.lcomm space_flag, 4    #1 sau dau cach->chu dau viet hoa, 0: chu thuong
.lcomm output, 256
.lcomm out_len,4
.section .text
.globl _start

_start:
        movl $4, %eax   # 4-syscall write
        movl $1, %ebx   #1 - STDOUT
        movl $msg_in, %ecx      #input
        movl $28, %edx
        int $0x80

        movl $3, %eax   #3-syscall read
        movl $0, %ebx   # 0-STDIN
        movl $input, %ecx
        movl  $255, %edx
        int $0x80

        movl $1, space_flag #dau chuoi viet hoa
        movl $0, out_len #khoi tao do dai output ban dau

        movl $input, %esi #dau chuoi input vao esi (doc)
        movl $output, %edi #output->edi (ghi)

normal_loop:
        movb (%esi), %al        #%al luu ki tu hien tai
        cmpb $0x0A, %al #kiem tra newline (cuoi chuoi)
        je print_res    #neu = newline, het chuoi, chuyen qua in ket qua

        cmpb $' ', %al
        je is_space     #xu ly flag khoang trang

        #xu ly chu cai
        cmpb $'A', %al
        jl store_char #neu < 'A'-> ky tu dac biet, luu nguyen
        cmpb $'z', %al
        jg store_char   #luu nguyen 

        #x ly chu hoa
        cmpb $'Z', %al
        jle is_upper #xu ly ki tu hoa -> can chuyen thuong neu khong phai dau tu
        #xu ly chu thuong
        cmpb $'a', %al
        jge is_lower #xu ly ki tu thuong -> chuyen hoa neu dau cau
        jmp next_char

is_upper:
        movl space_flag, %ebx #kiem tra co de xu ly ky tu
        cmpl $1, %ebx
        jne lower #khong phai dau tu thi chuyen thuong
        movl $0, space_flag #Dau tu giu nguyen
        jmp store_char #luu lai vao output

is_lower:
        movl space_flag, %ebx #kiem tra co
        cmpl $1, %ebx 
        jne keep_lower #khong phai chu dau -> giu nguyen thuong
        subb $32, %al #chu dau thi -32 chuyen hoa
        movl $0, space_flag
        jmp store_char  #luu

lower:
        addb $32, %al   #+32 chuyen thuong
        movl $0, space_flag 
        jmp store_char

keep_lower:
        movl $0, space_flag     #dat lai co (dang o trong t)
        jmp store_char

is_space:
        movl $1, space_flag # bat co sau dau cach
        #luu nguyen dau cach
store_char:
        movb %al, (%edi) #ghi ky tu vao vung nho output
        incl %edi #tang con tro output
        movl out_len, %ebx 
        incl %ebx #out_len++
        movl %ebx, out_len

next_char:
        incl %esi #chuyen qua o nho ky tu tiep theo
        jmp normal_loop # ve vong lap xu ly tiep
print_res:
        movl $4, %eax            # 4 - syscall write
        movl $1, %ebx            # 1 - STDOUT
        movl $msg_out, %ecx
        movl $17, %edx
        int $0x80

        movl $4, %eax            # 4 - syscall write
        movl $1, %ebx            # 1 - STDOUT
        movl $output, %ecx
        movl out_len, %edx
        int $0x80

        movl $1, %eax            # 1 - syscall exit
        int  $0x80               # Thoat
