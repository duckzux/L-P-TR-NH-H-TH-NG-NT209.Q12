.section .data
	InputGuide: .string "CCCD: "                      # Chuỗi hướng dẫn nhập CCCD
	NamSinhGuide: .string "Nam sinh: "                # Chuỗi in ra "Nam sinh: "
	GioiTinhGuide: .string "Gioi tinh: "              # Chuỗi in ra "Gioi tinh: "
	NamNu: .byte 0 		                             # Biến lưu giới tính (0 = Nam, 1 = Nữ), mặc định là 0
	Nam: .string "Nam"                                # Chuỗi in ra "Nam"
	Nu: .string "Nu"                                  # Chuỗi in ra "Nu"
	ChuaLD: .string "Chua den do tuoi lao dong"       # Chuỗi kết quả: Chưa đến độ tuổi lao động
	TrongLD: .string "Trong do tuoi lao dong"         # Chuỗi kết quả: Trong độ tuổi lao động
	HetLD: .string "Het do tuoi lao dong"             # Chuỗi kết quả: Hết độ tuổi lao động
	enter: .string "\n"	                             # Ký tự xuống dòng

.section .bss
	.lcomm CCCD, 12		# Tạo biến để nhận input CCCD
	.lcomm NamSinh, 4	# Tạo biến chứa kết quả tính toán năm sinh
	.lcomm Tuoi,4		# Tạo biến chứa kết quả tính toán tuổi
	
.section .text
	.globl _start
_start:
	movl $4,%eax		# syscall sys_write
	movl $1,%ebx		# stdout
	movl $InputGuide,%ecx	# Địa chỉ chuỗi "CCCD: "
	movl $6,%edx		# Độ dài chuỗi
	int $0x80		# Thực thi syscall
	
	movl $3,%eax		# syscall sys_read
	movl $0,%ebx		# stdin
	movl $CCCD,%ecx	# Địa chỉ lưu chuỗi được nhập vào
	movl $13,%edx		# Độ dài chuỗi input
	int $0x80		# Thực thi syscall
	
	movl $CCCD,%eax	# Lưu địa chỉ CCCD vào %eax (Base Register)
	
	movb 3(%eax),%bl 	# Lấy ký tự thứ 4 (offset 3) vào %bl
	subb $0x30,%bl		# Chuyển ký tự về dạng số (0, 1, 2, 3, ...)
	
# Xét nam nữ, nếu là nữ thì NamNu = 1
	cmp $1,%bl		# So sánh %bl với 1
	je Set_NamNu		# Nhảy tới Set_NamNu nếu %bl = 1
	
	cmp $3,%bl		# So sánh %bl với 3
	je Set_NamNu		# Nhảy tới Set_NamNu nếu %bl = 3
	
	jmp END_IF		# Nhảy tới END_IF
	
Set_NamNu:
	movb $1,NamNu		# Gán NamNu = 1

END_IF:
	cmp $2,%bl		# So sánh %bl với 2 (Xét 20XX hay 19XX)
	jl NAMSINH_19XX		# Nhảy tới NAMSINH_19XX nếu %bl < 2
	
# NĂM SINH 20XX khi bl >= 2
	movb $2,NamSinh		# NamSinh[0] = 2
	movb $0,NamSinh + 1	# NamSinh[1] = 0

	jmp END_IF2		# Nhảy tới END_IF2
NAMSINH_19XX:
	movb $1,NamSinh		# Gán NamSinh[0] = 1 	
	movb $9,NamSinh + 1	# Gán NamSinh[1] = 9
END_IF2:
	
	
	movb 4(%eax),%bl 	# Lấy ký tự thứ 5 (offset 4)
	subb $0x30,%bl		# Chuyển ký tự về dạng số
	movb %bl,NamSinh + 2	# Gán NamSinh[2] = chữ số thập thứ 1
	
	movb 5(%eax),%bl 	# Lấy ký tự thứ 6 (offset 5)
	subb $0x30,%bl		# Chuyển ký tự về dạng số
	movb %bl,NamSinh + 3	# Gán NamSinh[3] = chữ số thập thứ 2
	
# Thực hiện tính toán tuổi
	movl $0,%ebx	# Xóa EBX (chứa năm sinh hoàn chỉnh)

# 1. Tính: Mã thế kỷ * 1000
	xorl %eax,%eax	# EAX = 0
	movb NamSinh,%al	# Tải NamSinh[0] vào AL
	movl $1000,%ecx
	mull %ecx
	addl %eax,%ebx		# EBX += 1000 hoặc 2000

# 2. Tính: Chữ số thứ 2 * 100
	xorl %eax,%eax	# EAX = 0
	movb NamSinh + 1,%al	# Tải NamSinh[1] vào AL
	movl $100,%ecx
	mull %ecx
	addl %eax,%ebx		# EBX += 900 hoặc 0

# 3. Tính: Chữ số thứ 3 * 10
	xorl %eax,%eax	# EAX = 0
	movb NamSinh + 2,%al	# Tải NamSinh[2] vào AL
	movl $10,%ecx
	mull %ecx
	addl %eax,%ebx	# EBX += 90 (Hàng chục)

# 4. Tính: Chữ số thứ 4 * 1
	xorl %eax,%eax	# EAX = 0
	movb NamSinh + 3,%al	# Tải NamSinh[3] vào AL
	addl %eax,%ebx	# EBX += chữ số cuối. EBX = NĂM SINH HOÀN CHỈNH.
	
# TÍNH TUỔI (Lưu vào Tuoi)
	movl $2025,%eax
	subl %ebx,%eax	# EAX = 2025 - NamSinh. Tuổi nằm trong EAX
	movl %eax,Tuoi	# Tuoi chứa tuổi

# Đưa NamSinh thành ký tự
	movl $0,%ecx	# i = 0
	movl $NamSinh,%eax	# EAX = Địa chỉ NamSinh
.loop:
	movb (%eax,%ecx),%bl	# NamSinh[i] lưu vào %bl
	addb $0x30,%bl			# Chuyển từ số sang ký tự
	movb %bl,(%eax,%ecx)	# Lưu ngược ký tự trong %bl về NamSinh[i]

	incl %ecx				# i = i+1
	cmpl $3,%ecx			# while i <= 3
	jle .loop				# Nhảy về loop

	movl $4,%eax			# syscall sys_write "Năm sinh: "
	movl $1,%ebx			# stdout
	movl $NamSinhGuide,%ecx	# Địa chỉ chuỗi "Năm sinh: "
	movl $10,%edx			# Độ dài chuỗi
	int $0x80				# Thực thi syscall

	movl $4,%eax			# write Năm sinh
	movl $1,%ebx			# stdout
	movl $NamSinh,%ecx		# Địa chỉ NamSinh
	movl $4,%edx			# Độ dài chuỗi
	int $0x80				# Thực thi syscall
	
	movl $4,%eax			# syscall sys_write
	movl $1,%ebx			# stdout
	movl $enter,%ecx		# Địa chỉ enter
	movl $1,%edx			# Độ dài chuỗi \n
	int $0x80				# Thực thi syscall
	
	movl $4,%eax			# syscall sys_write
	movl $1,%ebx			# stdout
	movl $GioiTinhGuide,%ecx	# Địa chỉ chuỗi "Giới tính: "
	movl $11,%edx			# Độ dài chuỗi "Giới tính: "
	int $0x80				# Thực thi syscall
	
	movb NamNu,%al			# Gán giá trị trong NamNu vào %al
	
	cmp $1,%al				# So sánh %al với 1 để làm điều kiện rẽ nhánh
	je PRINT_NU				# Nhảy tới PRINT_NU nếu %al=1
	
	movl $Nam,%ecx			# Gán ECX là địa chỉ của "Nam" chuẩn bị cho PRINT_GENDER
	movl $3,%edx			# Gán EDX là độ dài chuỗi "Nam" chuẩn bị cho PRINT_GENDER
	jmp PRINT_GENDER		# Nhảy tới PRINT_GENDER
	
PRINT_NU:
	movl $Nu,%ecx			# Gán ECX là địa chỉ của "Nữ" chuẩn bị cho PRINT_GENDER
	movl $2,%edx			# Gán EDX là độ dài chuỗi "Nữ" chuẩn bị cho PRINT_GENDER
PRINT_GENDER:
	movl $4,%eax			# syscall sys_write
	movl $1,%ebx			# stdout
	int $0x80 				# Thực thi syscall in giới tính

	movl $4,%eax		# syscall sys_write
	movl $1,%ebx		# stdout
	movl $enter,%ecx	# Địa chỉ chuỗi "\n"
	movl $1,%edx		# Độ dài chuỗi "\n"
	int $0x80			# Thực thi syscall

# Xét tuổi lao động
# Xét giới tính
	movb NamNu,%al		# Gán giá trị trong NamNu vào %al để đem đi so sánh
	
	cmp $1,%al			# So sánh %al với 1 để làm điều kiện rẽ nhánh
	je CHECK_TUOILD_NU	# Nhảy nếu %al = 1
	
	# Check tuổi NAM (Ngưỡng 60)
	cmpl $15,Tuoi		# Tuổi < 15?
	jl CHUA_LAO_DONG	# Nhảy tới nếu thỏa điều kiện

	cmpl $60,Tuoi		# Tuổi > 60?
	jg HET_LAO_DONG		# Nhảy nếu thỏa điều kiện

	jmp TRONG_LAO_DONG  # Nhảy tới TRONG_LAO_DONG

	# Check tuổi Nữ (Ngưỡng 55)
CHECK_TUOILD_NU:

	cmpl $15,Tuoi		# Tuổi < 15?
	jl CHUA_LAO_DONG	# Nhảy nếu thỏa điều kiện
	cmpl $55,Tuoi		# Tuổi > 55?
	jg HET_LAO_DONG		# Nhảy nếu thỏa điều kiện

	jmp TRONG_LAO_DONG	# Nhảy tới TRONG_LAO_DONG

CHUA_LAO_DONG:
	movl $ChuaLD,%ecx	# Gán ECX là địa chỉ của chuỗi "Chưa đến độ tuổi lao động" chuẩn bị cho PRINT_FINAL_RESULT
	movl $26,%edx		# Độ dài chuỗi "Chưa đến độ tuổi lao động"
	jmp PRINT_FINAL_RESULT	# Nhảy tới PRINT_FINAL_RESULT

TRONG_LAO_DONG:
	movl $TrongLD,%ecx	# Gán ECX là địa chỉ của chuỗi "Trong độ tuổi lao động" chuẩn bị cho PRINT_FINAL_RESULT
	movl $23,%edx		# Độ dài chuỗi "Trong độ tuổi lao động"
	jmp PRINT_FINAL_RESULT	# Nhảy tới PRINT_FINAL_RESULT

HET_LAO_DONG:
	movl $HetLD,%ecx	# Gán ECX là địa chỉ của chuỗi "Hết độ tuổi lao động" chuẩn bị cho PRINT_FINAL_RESULT
	movl $21,%edx		# Độ dài chuỗi "Hết độ tuổi lao động"
	jmp PRINT_FINAL_RESULT	# Nhảy tới PRINT_FINAL_RESULT

PRINT_FINAL_RESULT:
	movl $4,%eax	# Syscall write
	movl $1,%ebx	# stdout
	int $0x80	# Thực thi syscall in TRẠNG THÁI LAO ĐỘNG

	movl $4,%eax			# syscall sys_write
	movl $1,%ebx			# stdout
	movl $enter,%ecx		# Địa chỉ enter
	movl $1,%edx			# Độ dài chuỗi \n
	int $0x80				# Thực thi syscall

	movl $1,%eax	# Syscall exit
	movl $0,%ebx	# stdout
	int $0x80		# Thực thi syscall
