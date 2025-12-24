.section .data
	msg1: .string "Date (DDMMYYYY): " #chuỗi cố định, in ra màn hình 
	msg2: .string "Date (YYYYDDMM): " #chuỗi cố định, in ra màn hình

.section .bss
           .lcomm num1, 8 #cấp phát 8 byte trống để chứa dữ liệu cho người dùng nhập vào theo format DDMMYYYY
           .lcomm num2, 8 #cấp phát 8 byte để chứa kết quả đã chuyển đổi YYYYMMDD 

.section .text
    .globl _start
_start:
    #hiển thị chuôi Date (DDMMYYYY): để user nhập vào
    movl $4, %eax		#syscall write
    movl $1, %ebx		#stdout
    movl $msg1, %ecx 	#địa chỉ chuỗi msg1
    movl $16, %edx   	#độ dài chuỗi msg1
    int $0x80
    
    #đọc chuỗi ngày tháng năm từ bàn phím 
    movl $3, %eax		#syscall read 
    movl $0, %ebx		#stdin	
    movl $num1, %ecx	#buffer = num1
    movl $8, %edx       #đọc 8 byte (DDMMYYYY)
    int $0x80

	#chuyển đổi định dạng ngày
    movl $num1, %eax       	#%eax tro ve input de chuyen doi ngay thang nam theo de yeu cau

	#copy từng ký tự theo định dạng YYYYDDMM (ngược lại so với num1)
    mov 4(%eax), %bl        #lấy ký tự thứ 5 (Y1) từ trái sang phải 
    mov %bl, num2         	#lưu ký tự vừa rồi vào num2[0]
    mov 5(%eax), %bl        #Y2, tương tự với cách làm của Y1
    mov %bl, num2+1
    mov 6(%eax), %bl        #Y3, tương tự 
    mov %bl, num2+2
    mov 7(%eax), %bl        #Y4
    mov %bl, num2+3

    mov 0(%eax), %bl        #D1
    mov %bl, num2+4
    mov 1(%eax), %bl        #D2
    mov %bl, num2+5
    mov 2(%eax), %bl        #M1
    mov %bl, num2+6
    mov 3(%eax), %bl        #M2
    mov %bl, num2+7
    movb $0x0A, num2+8    	#thêm '\n' để xuống dòng 
    
    #in ra hàng thứ 2 với output đã được chỉnh sửa từ input tren
    movl $4, %eax			#syscall write
    movl $1, %ebx			#stdout
    movl $msg2, %ecx		#địa chỉ chuỗi msg1
    movl $17, %edx          #độ dài chuỗi msg1
    int $0x80

    #add them output vua moi doi o tren
    movl $4, %eax
    movl $1, %ebx
    movl $num2, %ecx
    movl $9, %edx 		  	#thêm ngày tháng năm đã chỉnh từ input bên trến (8 ký tự + '\n')
    int $0x80

    movl $1, %eax		#system call number (sys-exit)
    int $0x80			#call kernel
