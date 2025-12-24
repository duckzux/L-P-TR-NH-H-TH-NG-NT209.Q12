.section .data	
	rs:   .string "NT209Q12"
	len: .int 0				#len: ô nhớ 4 byte lưu độ dài ban đâu (=0)
	output: .string "0\n"	#Xuống dòng

.section .text
     .globl _start
_start:
    movl $len, %edi 	#gán địa chỉ của len vào thanh ghi %edi
    subl $rs, %edi  	#%edi = (&len) - (&rs), khoảng cách từ đầu rs đến đầu len bằng độ dài chuỗi + 1 vì có thêm '\0' ở cuối string
    subl $1, %edi   	#-1 để bỏ đi byte '\0' - ký tự null để nhận được độ dài thực của chuỗi
    movl %edi, len  	#độ dài của res đã lưu vào len

    movl len, %eax      # đọc giá trị của len và đưa vào %eax
    addl $48, %eax      # mã ascii của '0' là 48. Cộng thêm 48 để biến số thành ký tự (hoặc cũng có thể sử dụng 0x30 vì)
    movb %al, output    # lưu vào vùng nhớ output, ghi 1 byte thấp %al vào byte đầu của output 


    movl $4, %eax       # sys_write
    movl $1, %ebx       # stdout
    movl $output, %ecx  # đưa con trỏ đến vùng output cần in ra -> cho kernel biết vùng bộ đệm cần in 
	movl $2, %edx       # 2 byte = 3 tham số (có thêm '\0' nữa)
    int $0x80

    movl $1, %eax		#system call number (sys-exit)
    int $0x80			#call kernel
