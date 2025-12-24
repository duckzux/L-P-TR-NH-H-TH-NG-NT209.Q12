.section .data
msg_in:   .string "Enter a string (<255 chars):"   # Chuỗi yêu cầu nhập
msg_out:  .string "Chuoi chuan hoa: "              # Thông báo kết quả

.section .bss
    .lcomm input, 256        # Bộ nhớ lưu chuỗi nhập vào
    .lcomm output, 256       # Bộ nhớ lưu chuỗi đã chuẩn hóa (ghi riêng, không đè input)
    .lcomm space_flag, 1     # Vị trí hiện tại:
           # 1 sau dấu cách -> chữ tiếp theo là chữ cái đầu → viết hoa
           # 0 ở trong từ ->chữ tiếp theo là chữ thường
    .lcomm out_len, 4        # Số byte đã ghi vào output (để write đúng độ dài)

.section .text
    .globl _start
_start:
    movl $4, %eax           # 4 - syscall write
    movl $1, %ebx           # 1 - STDOUT
    movl $msg_in, %ecx       # Địa chỉ chuỗi thông báo
    movl $28, %edx           # Độ dài chuỗi
    int  $0x80              # Gọi hệ thống (in yêu cầu nhập)

    movl $3, %eax           # 3 - syscall read
    movl $0, %ebx           # 0 - STDIN
    movl $input, %ecx        # Địa chỉ vùng nhớ nhập
    movl $255, %edx          # Đọc tối đa 255 ký tự
    int  $0x80              # Gọi hệ thống (đọc từ bàn phím)

    movb $1, space_flag      # Khởi tạo: vị trí đầu chuỗi coi như sau dấu cách
    movl $0, out_len        # Đặt số byte đã ghi output = 0

    movl $input,  %edx       # edx địa chỉ chuỗi input
    movl $output, %edi       # edi địa chỉ chuỗi output 
_loop:
    movb (%edx), %al         # al = ký tự hiện tại 
    cmpb $0x0A, %al          # Ký tự newline?
    je print_res          # Nếu newline, kết thúc xử lý

    cmpb $' ', %al           # Là dấu cách?
    je is_space             # Nếu là khoảng trắng → xử lý cờ

    # Nếu là chữ cái
    cmpb $'A', %al
    jl store_char             # Nếu < 'A'  (ký tự đặc biệt) → lưu nguyên
    cmpb $'z', %al
    jg store_char             # Nếu > 'z'→ luư nguyên

    cmpb $'Z', %al
    jle upper          # Nếu nằm trong A-Z → chuyển thường nếu không đầu từ
    cmpb $'a', %al
    jge lower          # Nếu nằm trong a-z → dđầu từ viết hoa
    jmp next_char

upper:                 # al là chữ in hoa
    movb space_flag, %bl
    cmpl $1, %ebx       # kiểm tra có phải đầu từ
    jne make_lower          # Nếu không phải đầu từ → chuyển sang thường
    movb $0, space_flag      # Nếu đầu từ → giữ nguyên in hoa
    jmp store_char

lower:                 # al là chữ thường
    movb space_flag, %bl
    cmpl $1, %ebx
    jne keep_lower          # Nếu không phải đầu từ → giữ nguyên thường
    subb $32, %al          # Nếu đầu từ → chuyển thành in hoa ('a'→'A')
    movb $0, space_flag         # set lai flag
    jmp store_char

make_lower:
    addb $32, %al            # Chuyển in hoa → thường
    movb $0, space_flag
    jmp store_char

keep_lower:
    movb $0, space_flag      # Đặt lại cờ (không ở dđầu từ
    jmp store_char

is_space:
    movb $1, space_flag      # Nếu gặp dấu cách → bật cờ “sau cách”
    # xuống store_char để luuưu space 

store_char:
    movb %al, (%edi)         # Ghi ký tự đã xử lý vào output
    incl %edi                # Tăng con trỏ output
    movl out_len, %ebx       # out_len++
    incl %ebx
    movl %ebx, out_len
next_char:
    incl %edx                # Sang ký tự tiếp theo của input
    jmp _loop       # Quay lại vòng lặp

print_res:
    movl $4, %eax           # 4 - syscall write
    movl $1, %ebx           # 1 - STDOUT
    movl $msg_out, %ecx      # Chuỗi thông báo kết quả
    movl $17, %edx           # Độ dài 17 ký tự
    int  $0x80              # In ra thông báo

    movl $4, %eax           # 4 - syscall write
    movl $1, %ebx           # 1 - STDOUT
    movl $output, %ecx       # Địa chỉ chuỗi đã chuẩn hóa (output)
    movl out_len, %edx       # In đúng số byte đã ghi
    int  $0x80             # Gọi hệ thống (in kết quả)

    movl $1, %eax            # 1 - syscall exit
    int  $0x80              # Thoát chương trình
