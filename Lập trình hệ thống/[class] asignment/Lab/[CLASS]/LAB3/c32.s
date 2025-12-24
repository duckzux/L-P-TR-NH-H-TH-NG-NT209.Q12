.section .data
msg_in:   .string "Enter a string (<255 chars):"   # Chuỗi yêu cầu nhập
msg_out:  .string "\nChuoi chuan hoa: \n"         # Thông báo kết quả

.section .bss
    .lcomm input, 256        # Bộ nhớ lưu chuỗi nhập vào
    .lcomm space_flag, 4     # Biến trạng thái: 1 = sau dấu cách, 0 = trong từ

.section .text
    .globl _start
_start:
    movl $4, %eax            # 4 - syscall write
    movl $1, %ebx            # 1 - STDOUT
    movl $msg_in, %ecx       # Địa chỉ chuỗi thông báo
    movl $28, %edx           # Độ dài chuỗi
    int  $0x80               # Gọi hệ thống (in lời nhắc)

    movl $3, %eax            # 3 - syscall read
    movl $0, %ebx            # 0 - STDIN
    movl $input, %ecx        # Địa chỉ vùng nhớ nhập
    movl $255, %edx          # Đọc tối đa 255 ký tự
    int  $0x80               # Gọi hệ thống (đọc từ bàn phím)

    movl $1, space_flag      # Khởi tạo: vị trí đầu chuỗi coi như sau dấu cách

    movl $input, %esi        # ESI = địa chỉ chuỗi
normalize_loop:
    movb (%esi), %al         # AL = ký tự hiện tại
    cmpb $0x0A, %al          # Ký tự newline?
    je print_result          # Nếu newline, kết thúc xử lý

    cmpb $' ', %al           # Là dấu cách?
    je is_space              # Nếu là khoảng trắng → xử lý cờ

    # Nếu là chữ cái
    cmpb $'A', %al
    jl next_char             # Nếu < 'A' thì bỏ qua (ký tự đặc biệt)
    cmpb $'z', %al
    jg next_char             # Nếu > 'z' thì bỏ qua

    cmpb $'Z', %al
    jle upper_range          # Nếu nằm trong A-Z → có thể cần hạ xuống
    cmpb $'a', %al
    jge lower_range          # Nếu nằm trong a-z → có thể cần viết hoa
    jmp next_char

upper_range:                 # AL là chữ in hoa
    movl space_flag, %ebx
    cmpl $1, %ebx
    jne make_lower           # Nếu không phải đầu từ → chuyển sang thường
    movl $0, space_flag      # Nếu đầu từ → giữ nguyên in hoa
    jmp store_char

lower_range:                 # AL là chữ thường
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
    movl $0, space_flag      # Đặt lại cờ (đang trong từ)
    jmp store_char

is_space:
    movl $1, space_flag      # Nếu gặp dấu cách → bật cờ “sau cách”
    jmp store_char

store_char:
    movb %al, (%esi)         # Ghi ký tự đã xử lý vào vị trí cũ
next_char:
    incl %esi                # Sang ký tự tiếp theo
    jmp normalize_loop       # Quay lại vòng lặp

print_result:
    movl $4, %eax            # 4 - syscall write
    movl $1, %ebx            # 1 - STDOUT
    movl $msg_out, %ecx      # Chuỗi thông báo kết quả
    movl $22, %edx           # Độ dài chuỗi
    int  $0x80               # In ra thông báo

    movl $4, %eax            # 4 - syscall write
    movl $1, %ebx            # 1 - STDOUT
    movl $input, %ecx        # Địa chỉ chuỗi đã chuẩn hóa
    movl $255, %edx          # In tối đa 255 ký tự
    int  $0x80               # Gọi hệ thống (in kết quả)

    movl $1, %eax            # 1 - syscall exit
    xorl %ebx, %ebx          # EBX = 0 (mã thoát)
    int  $0x80               # Thoát chương trình
