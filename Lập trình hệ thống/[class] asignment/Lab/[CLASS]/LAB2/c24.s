.section .data
	guide: .string "Nhap 3 ky tu thuong: "   # Chuỗi hướng dẫn yêu cầu người dùng nhập 3 ký tự thường
	result: .string "Chuoi in hoa: "         # Chuỗi thông báo sẽ in ra trước kết quả
	
.section .bss
	.lcomm input,4        # Vùng nhớ để lưu chuỗi nhập vào (3 ký tự + ký tự xuống dòng hoặc null)

.section .text
	.globl _start
_start:
	# In ra chuỗi hướng dẫn nhập
	movl $4, %eax		# syscall sys_write (mã số 4)
	movl $1, %ebx 		# tham số 1: fd = 1 (stdout)
	movl $guide, %ecx 	# tham số 2: địa chỉ chuỗi "Nhap 3 ky tu thuong: "
	movl $20, %edx 		# tham số 3: độ dài chuỗi hướng dẫn (20 byte)
	int $0x80			# thực thi system call (in ra màn hình)

	# Đọc chuỗi người dùng nhập
	movl $3, %eax		# syscall sys_read (mã số 3)
	movl $0, %ebx		# tham số 1: fd = 0 (stdin)
	movl $input, %ecx	# tham số 2: địa chỉ vùng nhớ để lưu chuỗi nhập
	movl $4, %edx		# tham số 3: số byte cần đọc (3 ký tự + 1 byte xuống dòng)
	int $0x80		# thực thi system call (đọc từ bàn phím)

	# Chuyển đổi ký tự thứ nhất sang chữ in hoa
	movl $input, %eax 	# lưu địa chỉ chuỗi input vào %eax
	movb (%eax), %bl	# lấy ký tự đầu tiên vào %bl
	subb $0x20, %bl		# trừ đi 32 (0x20) để đổi từ chữ thường sang chữ IN HOA
	movb %bl,(%eax) 	# lưu lại ký tự in hoa vào vị trí ký tự đầu tiên

	# Chuyển đổi ký tự thứ hai sang chữ in hoa
	movb 1(%eax), %bl	# lấy ký tự thứ hai vào %bl
	subb $0x20, %bl		# trừ đi 32 để đổi sang chữ in hoa
	movb %bl,1(%eax) 	# lưu ký tự in hoa vào vị trí ký tự thứ hai

	# Chuyển đổi ký tự thứ ba sang chữ in hoa
	movb 2(%eax), %bl	# lấy ký tự thứ ba vào %bl
	subb $0x20, %bl		# trừ đi 32 để đổi sang chữ in hoa
	movb %bl,2(%eax) 	# lưu ký tự in hoa vào vị trí ký tự thứ ba

	# In ra chuỗi "Chuoi in hoa: "
	movl $4, %eax		# syscall sys_write
	movl $1, %ebx		# fd = 1 (stdout)
	movl $result, %ecx	# địa chỉ chuỗi "Chuoi in hoa: "
	movl $13, %edx		# độ dài chuỗi (13 byte)
	int $0x80			# thực thi system call

	# In ra chuỗi input đã được chuyển đổi sang chữ in hoa
	movl $4, %eax		# syscall sys_write
	movl $1, %ebx		# fd = 1 (stdout)
	movl $input, %ecx	# địa chỉ chuỗi input đã được chuyển đổi
	movl $4, %edx		# số byte in ra (3 ký tự + xuống dòng)
	int $0x80			# thực thi system call

	#Thoát chương trình
	movl $1, %eax		#system call number (sys-exit)
	int $0x80			#call kernel
