.section .data
    msg1: .string "Enter number 1st (1-digit): "   # Thông báo yêu cầu nhập số thứ 1
    len1 = . - msg1                               # Độ dài chuỗi msg1
    msg2: .string "Enter number 2nd (1-digit): "  # Thông báo yêu cầu nhập số thứ 2
    len2 = . - msg2                               # Độ dài chuỗi msg2
    msg3: .string "Enter number 3rd (1-digit): "  # Thông báo yêu cầu nhập số thứ 3
    len3 = . - msg3                               # Độ dài chuỗi msg3
    msg4: .string "Enter number 4th (1-digit): "  # Thông báo yêu cầu nhập số thứ 4
    len4 = . - msg4                               # Độ dài chuỗi msg4
    msg5: .string "Enter number 5th (1-digit): "  # Thông báo yêu cầu nhập số thứ 5
    len5 = . - msg5                               # Độ dài chuỗi msg5

    out: .string "Count (>=5): "                  # Chuỗi thông báo kết quả
    out_len = . - out                             # Độ dài chuỗi out

    newline: .string "\n"                         # Ký tự xuống dòng
    newline_len = . - newline                     # Độ dài chuỗi newline

.section .bss
    .lcomm num, 2     # Khai báo vùng nhớ tên num gồm 2 byte để lưu số nhập vào (1 ký tự + '\n')
    .lcomm count, 4   # Khai báo vùng nhớ tên count gồm 4 byte để lưu biến đếm số >=5
    .lcomm index, 4   # Khai báo vùng nhớ tên index gồm 4 byte để lưu chỉ số các số nhập vào

.section .text
    .globl _start
_start:
    movl $0, count    # Khởi tạo biến count = 0
    movl $0, index    # Khởi tạo biến index = 0 (bắt đầu từ số đầu tiên)

loop:
    cmpl $5, index    # So sánh index với 5 (nếu index = 5 thì đã nhập đủ 5 số)
    je end_loop       # Nếu đủ 5 số thì thoát vòng lặp

    # In ra thông báo yêu cầu nhập số, phụ thuộc vào index
    movl $4, %eax     # syscall: sys_write
    movl $1, %ebx     # stdout
    cmpl $0, index    # Nếu index = 0 thì in msg1
    je msg_1
    cmpl $1, index    # Nếu index = 1 thì in msg2
    je msg_2
    cmpl $2, index    # Nếu index = 2 thì in msg3
    je msg_3
    cmpl $3, index    # Nếu index = 3 thì in msg4
    je msg_4
    jmp msg_5         # Nếu không phải các trường hợp trên → in msg5

msg_1:
    movl $msg1, %ecx  # Địa chỉ chuỗi msg1
    movl $len1, %edx  # Độ dài msg1
    jmp print
msg_2:
    movl $msg2, %ecx  # Địa chỉ chuỗi msg2
    movl $len2, %edx
    jmp print
msg_3:
    movl $msg3, %ecx  # Địa chỉ chuỗi msg3
    movl $len3, %edx
    jmp print
msg_4:
    movl $msg4, %ecx  # Địa chỉ chuỗi msg4
    movl $len4, %edx
    jmp print
msg_5:
    movl $msg5, %ecx  # Địa chỉ chuỗi msg5
    movl $len5, %edx

print:
    int $0x80         # Gọi syscall in chuỗi thông báo

    # Đọc input từ bàn phím
    movl $3, %eax     # syscall: sys_read
    movl $0, %ebx     # stdin
    movl $num, %ecx   # Địa chỉ vùng nhớ lưu input
    movl $2, %edx     # Đọc tối đa 2 byte (số + '\n')
    int $0x80         # Gọi syscall đọc dữ liệu

    # Chuyển ký tự ASCII sang số
    movzbl num, %eax  # Lấy ký tự đầu tiên (số nhập) đưa vào eax
    sub $0x30, %eax   # Chuyển ký tự ASCII sang số thực ('0' → 0, '5' → 5, ...)

    # Kiểm tra nếu số >= 5
    cmpl $5, %eax     # So sánh giá trị nhập với 5
    jl skip           # Nếu nhỏ hơn 5 thì bỏ qua
    incl count        # Nếu >= 5 thì tăng biến count thêm 1

skip:
    incl index        # Tăng index để chuyển sang số tiếp theo
    jmp loop          # Quay lại đầu vòng lặp để xử lý tiếp

end_loop:
    # In chuỗi thông báo "Count (>=5): "
    movl $4, %eax
    movl $1, %ebx
    movl $out, %ecx   # Địa chỉ chuỗi out
    movl $out_len, %edx
    int $0x80

    # In ra giá trị biến count
    movl count, %eax  # Lấy giá trị count đưa vào eax
    add $0x30, %eax   # Chuyển từ số sang ký tự ASCII
    movl %eax, num    # Lưu ký tự này vào biến num

    movl $4, %eax     # syscall: sys_write
    movl $1, %ebx
    movl $num, %ecx   # In ký tự trong num
    movl $1, %edx     # Độ dài 1 ký tự
    int $0x80

    # Xuống dòng sau khi in kết quả
    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $newline_len, %edx
    int $0x80

    # Kết thúc chương trình
    movl $1, %eax     # syscall: sys_exit
    int $0x80
