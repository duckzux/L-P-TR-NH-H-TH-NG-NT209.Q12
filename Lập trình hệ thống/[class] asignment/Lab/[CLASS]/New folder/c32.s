.section .data
msg_in:   .string "Enter a string (<255 chars):"   # Chuỗi yêu cầu nhập
msg_out:  .string "Chuoi chuan hoa: "              # Thông báo kết quả

.section .bss
    .lcomm input, 256        # Bộ nhớ lưu chuỗi nhập vào
    .lcomm output, 256       # Bộ nhớ lưu chuỗi đã chuẩn hóa (ghi riêng, không đè input)
    .lcomm space_flag, 4     # Vị trí hiện tại:
	   # 1 sau dấu cách -> chữ tiếp theo là chữ cái đầu → viết hoa
	   # 0 ở trong từ ->chữ tiếp theo là chữ thường
    .lcomm out_len, 4        # Số byte đã ghi vào output (để write đúng độ dài)

.section .text
    .globl _start
_start:
    movl $4, %eax            # 4 - syscall write
    movl $1, %ebx            # 1 - STDOUT
    movl $msg_in, %ecx       # Địa chỉ chuỗi thông báo
    movl $28, %edx           # Độ dài chuỗi
    int  $0x80               # Gọi hệ thống (in yêu cầu nhập)

    movl $3, %eax            # 3 - syscall read
    movl $0, %ebx            # 0 - STDIN
    movl $input, %ecx        # Địa chỉ vùng nhớ nhập
    movl $255, %edx          # Đọc tối đa 255 ký tự
    int  $0x80               # Gọi hệ thống (đọc từ bàn phím)

    movl $1, space_flag      # Khởi tạo: vị trí đầu chuỗi coi như sau dấu cách
    movl $0, out_len         # Đặt số byte đã ghi output = 0

    movl $input,  %esi       # esi= địa chỉ chuỗi input (đọc)
    movl $output, %edi       # edi= địa chỉ chuỗi output (ghi)
normalize_loop:
    movb (%esi), %al         # al = ký tự hiện tại (từ input)
    cmpb $0x0A, %al          # Ký tự newline?
    je print_result          # Nếu newline, kết thúc xử lý

    cmpb $' ', %al           # Là dấu cách?
    je is_space              # Nếu là khoảng trắng → xử lý cờ

    # Nếu là chữ cái
    cmpb $'A', %al
    jl store_char             # Nếu < 'A' thì bỏ qua (ký tự đặc biệt) → lưu nguyên
    cmpb $'z', %al
    jg store_char             # Nếu > 'z' thì bỏ qua → luư nguyên

    cmpb $'Z', %al
    jle upper_range          # Nếu nằm trong A-Z → có thể cần hạ xuống
    cmpb $'a', %al
    jge lower_range          # Nếu nằm trong a-z → có thể cần viết hoa
    jmp next_char

upper_range:                 # al là chữ in hoa
    movl space_flag, %ebx
    cmpl $1, %ebx
    jne make_lower           # Nếu không phải đầu từ → chuyển sang thường
    movl $0, space_flag      # Nếu đầu từ → giữ nguyên in hoa
    jmp store_char

lower_range:                 # al là chữ thường
    movl space_flag, %ebx
    cmpl $1, %ebx
    jne keep_lower           # Nếu không phải đầu từ → giữ nguyên thường
    subb $32, %al            # Nếu đầu từ → chuyển thành in hoa ('a'→'A')
    movl $0, space_flag
    jmp store_char

make_lower:
    addb $32, %al            # Chuyển in hoa → thường
    movl $0, space_flag
    jmp store_char

keep_lower:
    movl $0, space_flag      # Đặt lại cờ (không ở dđầu từ
    jmp store_char

is_space:
    movl $1, space_flag      # Nếu gặp dấu cách → bật cờ “sau cách”
    # xuống store_char để luuưu space 

store_char:
    movb %al, (%edi)         # Ghi ký tự đã xử lý vào output
    incl %edi                # Tăng con trỏ output
    movl out_len, %ebx       # out_len++
    incl %ebx
    movl %ebx, out_len
next_char:
    incl %esi                # Sang ký tự tiếp theo của input
    jmp normalize_loop       # Quay lại vòng lặp

print_result:
    movl $4, %eax            # 4 - syscall write
    movl $1, %ebx            # 1 - STDOUT
    movl $msg_out, %ecx      # Chuỗi thông báo kết quả
    movl $17, %edx           # Độ dài 17 ký tự
    int  $0x80               # In ra thông báo

    movl $4, %eax            # 4 - syscall write
    movl $1, %ebx            # 1 - STDOUT
    movl $output, %ecx       # Địa chỉ chuỗi đã chuẩn hóa (output)
    movl out_len, %edx       # In đúng số byte đã ghi
    int  $0x80               # Gọi hệ thống (in kết quả)

    movl $1, %eax            # 1 - syscall exit
    int  $0x80               # Thoát chương trình
