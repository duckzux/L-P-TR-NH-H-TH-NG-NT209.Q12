.section .data
msg_in:   .string "Enter a number (5-digit):"   # Chuỗi yêu cầu nhập số
msg_dec:  .string "Giam dan\n"                  # Chuỗi kết quả nếu giảm dần
msg_inc:  .string "Khong giam dan\n"            # Chuỗi kết quả nếu không giảm dần
msg_err:  .string "So khong hop le\n"           # Chuỗi thông báo khi nhập input sai

.section .bss
    .lcomm input, 8         # Vùng nhớ lưu chuỗi nhập có kích thước là 8 (min: 5 ký tự + '\n')

.section .text
    .globl _start
_start:
    movl $4, %eax           # 4 - system_write
    movl $1, %ebx           # 1 - STDOUT để xuất chuỗi yêu cầu nhập
    movl $msg_in, %ecx      # Địa chỉ chuỗi msg_in để in ra
    movl $26, %edx          # msg_in 26 ký tự
    int  $0x80              # system_call (in ra màn hình)

    movl $3, %eax           # 3 - system_read
    movl $0, %ebx           # 0 - STDIN để nhập số
    movl $input, %ecx       # Địa chỉ vùng nhớ để lưu chuỗi nhập
    movl $8, %edx           # Đọc tối đa 8 byte
    int  $0x80              # system_call (nhập vào)
    movl %eax, %esi         # Lưu số byte thực tế đọc được vào %esi

    cmpl $6, %esi           # Kiểm tra số byte đọc được có phải 6 (5 ký tự + '\n')
    jne invalid_input       # Khác 6 thì nhảy đến đoạn xử lý nhập sai

    movl $input, %eax       # Gán địa chỉ chuỗi input vào %eax
    movl $0, %edi           # %edi = 0 (số lần vòng lặp: duyệt đến chữ số i)

check_digit:
    movb (%eax,%edi,1), %bl # Đọc ký tự input[i] vào %bl
    cmpb $'\n', %bl         # Kiểm tra phải newline không
    je   check_done         # Newline thì kết thúc kiểm tra
    cmpb $'0', %bl          # So với '0'
    jl   invalid_input       # Nếu nhỏ hơn '0' không phải chữ số
    cmpb $'9', %bl          # So với '9'
    jg   invalid_input       # Nếu lớn hơn '9' không phải chữ số
    incl %edi               # i++
    cmpl $5, %edi           # Đọc đúng 5 ký tự thì hợp lệ
    jl   check_digit         # Nếu chưa thì lặp tiếp kiểm tra ký tự tiếp theo

check_done:
    movl $input, %eax       # Gán địa chỉ chuỗi input vào %eax
    #Dùng thanh ghi bl và bh để lưu chữ số n và n+1 của số input rồi so sánh 2 thanh ghi để kiểm tra
    movb 0(%eax), %bl       # %bl = input[0]
    movb 1(%eax), %bh       # %bh = input[1]
    cmpb %bh, %bl           # So sánh input[0] với input[1]
    jle  not_desc           # Nếu <= thì không giảm dần

    movb 1(%eax), %bl       # %bl = input[1]
    movb 2(%eax), %bh       # %bh = input[2]
    cmpb %bh, %bl           # So sánh input[1] với input[2]
    jle  not_desc           # Nếu <= thì không giảm dần

    movb 2(%eax), %bl       # %bl = input[2]
    movb 3(%eax), %bh       # %bh = input[3]
    cmpb %bh, %bl           # So sánh input[2] với input[3]
    jle  not_desc           # Nếu <= thì không giảm dần

    movb 3(%eax), %bl       # %bl = input[3]
    movb 4(%eax), %bh       # %bh = input[4]
    cmpb %bh, %bl           # So sánh input[3] với input[4]
    jle  not_desc           # Nếu <= thì không giảm dần

desc:
    movl $4, %eax           # 4 - system_write
    movl $1, %ebx           # 1 - STDOUT để in ra chuỗi
    movl $msg_dec, %ecx     # Địa chỉ chuỗi “Giam dan”
    movl $10, %edx          # Chuỗi 10 ký tự
    int  $0x80              # Gọi hệ thống (in kết quả)
    jmp  exit               # Kết thúc chương trình

not_desc:
    movl $4, %eax           # 4 - system_write
    movl $1, %ebx           # 1 - STDOUT để in ra chuỗi
    movl $msg_inc, %ecx     # Địa chỉ chuỗi “Khong giam dan”
    movl $15, %edx          # Chuỗi 15 ký tự
    int  $0x80              # system_call (in kết quả)
    jmp  exit               # Nhảy đến exit

invalid_input:
    movl $4, %eax           # 4 - system_write
    movl $1, %ebx           # 1 - STDOUT để in ra chuỗi
    movl $msg_err, %ecx     # Địa chỉ chuỗi “So khong hop le”
    movl $17, %edx          # Độ dài chuỗi = 17 ký tự
    int  $0x80              # system_call (in thông báo lỗi)

exit:
    movl $1, %eax           # 1 - system_exit
    int  $0x80              # system_call để thoát
