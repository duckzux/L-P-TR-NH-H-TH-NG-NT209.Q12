.section .data
	req1: .string "Enter a number : "   # Chuỗi thông báo yêu cầu người dùng nhập số
	newline: .string "\n"          		# Ký tự xuống dòng

.section .bss
	.lcomm mon1, 3                 # Bộ nhớ lưu điểm môn thứ nhất (tối đa 2 chữ số + \n)
	.lcomm mon2, 3                 # Bộ nhớ lưu điểm môn thứ hai (tối đa 2 chữ số + \n)
	.lcomm mon3, 3                 # Bộ nhớ lưu điểm môn thứ ba (tối đa 2 chữ số + \n)
	.lcomm mon4, 3                 # Bộ nhớ lưu điểm môn thứ tư (tối đa 2 chữ số + \n)
	.lcomm result, 3               # Bộ nhớ lưu kết quả trung bình (2 chữ số + \n)

.section .text
	.globl _start
_start:
# In thông báo nhập điểm môn thứ nhất
        movl $4, %eax          # 4 - system_write
        movl $1, %ebx          # 1 - STDOUT để xuất chuỗi yêu cầu nhập
        movl $req1, %ecx       # Địa chỉ của chuỗi req1 để in ra
        movl $17, %edx         # Độ dài chuỗi req1 = 17 ký tự
        int $0x80              # Gọi hệ thống (in ra màn hình)
# Nhập vào điểm môn thứ nhất
        movl $3, %eax          # 3 - system_read
        movl $0, %ebx          # 0 - STDIN để nhập dữ liệu
        movl $mon1, %ecx       # Địa chỉ vùng nhớ để lưu điểm môn 1
        movl $3, %edx          # Đọc tối đa 3 byte (2 chữ số + \n)
        int $0x80              # Gọi hệ thống (nhập từ bàn phím)
# In thông báo nhập điểm môn thứ hai
        movl $4, %eax          # 4 - system_write
        movl $1, %ebx          # 1 - STDOUT để xuất chuỗi yêu cầu nhập
        movl $req1, %ecx       # Địa chỉ của chuỗi req1 để in ra
        movl $17, %edx         # Độ dài chuỗi req1 = 17 ký tự
        int $0x80              # Gọi hệ thống (in ra màn hình)
# Nhập vào điểm môn thứ hai
        movl $3, %eax          # 3 - system_read
        movl $0, %ebx          # 0 - STDIN để nhập dữ liệu
        movl $mon2, %ecx       # Địa chỉ vùng nhớ để lưu điểm môn 2
        movl $3, %edx          # Đọc tối đa 3 byte
        int $0x80              # Gọi hệ thống (nhập từ bàn phím)
# In thông báo nhập điểm môn thứ ba
        movl $4, %eax          # 4 - system_write
        movl $1, %ebx          # 1 - STDOUT để xuất chuỗi yêu cầu nhập
        movl $req1, %ecx       # Địa chỉ của chuỗi req1 để in ra
        movl $17, %edx         # Độ dài chuỗi req1 = 17 ký tự
        int $0x80              # Gọi hệ thống (in ra màn hình)
# Nhập vào điểm môn thứ ba
        movl $3, %eax          # 3 - system_read
        movl $0, %ebx          # 0 - STDIN để nhập dữ liệu
        movl $mon3, %ecx       # Địa chỉ vùng nhớ để lưu điểm môn 3
        movl $3, %edx          # Đọc tối đa 3 byte
        int $0x80              # Gọi hệ thống (nhập từ bàn phím)

# In thông báo nhập điểm môn thứ tư
        movl $4, %eax          # 4 - system_write
        movl $1, %ebx          # 1 - STDOUT để xuất chuỗi yêu cầu nhập
        movl $req1, %ecx       # Địa chỉ của chuỗi req1 để in ra
        movl $17, %edx         # Độ dài chuỗi req1 = 17 ký tự
        int $0x80              # Gọi hệ thống (in ra màn hình)
# Nhập vào điểm môn thứ tư
        movl $3, %eax          # 3 - system_read
        movl $0, %ebx          # 0 - STDIN để nhập dữ liệu
        movl $mon4, %ecx       # Địa chỉ vùng nhớ để lưu điểm môn 4
        movl $3, %edx          # Đọc tối đa 3 byte
        int $0x80              # Gọi hệ thống (nhập từ bàn phím)
# Chuyển chuỗi nhập sang số rồi tính tổng để tính trung bình
        movl $0, %esi          # Khởi tạo tổng = 0 (lưu trong esi)
		
# Chuyển điểm sang dạng số
# mon1
        xorl %eax, %eax        # Xóa thanh ghi eax
        xorl %ebx, %ebx        # Xóa thanh ghi ebx
        movl $mon1, %ecx       # Đưa địa chỉ mon1 vào ecx
        movb (%ecx), %al       # Đọc ký tự đầu tiên vào al
        movb 1(%ecx), %bl      # Đọc ký tự thứ hai vào bl
        subb $'0', %al         # Trừ ký tự '0' để lấy giá trị số
        movsbl %al, %eax       # Mở rộng có dấu sang 32bit
        subb $'0', %bl         # Trừ ký tự '0' để lấy giá trị số nếu là \n thì sẽ có kết quả sau khi trừ là số âm
        movsbl %bl, %ebx       # Mở rộng có dấu sang 32bit
        movl %ebx, %edx
        sarl $31, %edx         # Kiểm tra nếu không có số thứ hai
			       # edx mask để xét dấu của byte thứ 2 của điểm:	
			       # 0 đối với ký tự '0' (trường hợp điểm 10),
			       # -1 (0xFFFFFFFF) với ký tự \n (điểm 1 → 9) để làm mask kiểm tra
	imull $10, %eax        # Nhân hàng chục với 10
        addl %ebx, %eax        # Cộng thêm hàng đơn vị 
       
        movzbl (%ecx), %ebx    # Lưu lại ký tự đầu tiên dạng 32 bit (nếu là số 1 chữ số(1->9) -> giá trị lấy để tính)
        subb $'0', %bl         # Chuyển ký tự về dạng số đối với số có 1 chữ số (ví dụ '5' -> 5) 
        notl %edx              # Đảo bit edx để tạo mask xét xem là số 2 chữ số không: -1 -> 0, 0-> -1 
        andl %edx, %eax        # Nếu có 2 chữ số thì giữ eax, nếu không thì xóa eax
			       # Nếu là số (1->9), mask là 0 -> giá trị trong eax trở thành 0 (trường hợp tính theo 2 chữ số không thỏa)
			       # Nếu là 10, mask là -1 (1111...11) -> and với 10 vẫn giữ nguyên kết quả trong eax là 10

        notl %edx              # Đảo lại edx về trạng thái cũ
        andl %edx, %ebx        # Nếu là 1 chữ số thì giữ ebx, nếu 2 thì xóa ebx
			       # Nếu là 10 mask là 0 -> and kết quả ra 0
			       # Ngược lại (1->9) mask là -1 (111..11) nếu and thì giá trị giữ nguyên

        orl %eax, %ebx         # Lựa chọn kết quả hợp lệ
        addl %ebx, %esi        # Cộng vào tổng
#mon2 tương tự
        xorl %eax, %eax        # xóa thanh ghi eax
        xorl %ebx, %ebx        # xóa thanh ghi ebx
        movl $mon2, %ecx       # đưa địa chỉ mon2 vào ecx
        movb (%ecx), %al       # đọc ký tự đầu tiên vào al
        movb 1(%ecx), %bl      # đọc ký tự thứ hai vào bl
        subb $'0', %al         # trừ ký tự '0' để lấy giá trị số
        movsbl %al, %eax       # mở rộng có dấu thành 32 bit
        subb $'0', %bl         # trừ ký tự '0' để lấy giá trị số
        movsbl %bl, %ebx       # mở rộng có dấu thành 32 bit
        movl %ebx, %edx
        sarl $31, %edx         # kiểm tra nếu không có số thứ hai
        imull $10, %eax        # nhân hàng chục với 10
        addl %ebx, %eax        # cộng thêm hàng đơn vị
        movzbl (%ecx), %ebx    # lưu lại ký tự đầu tiên (nếu chỉ có 1 chữ số thì đây là giá trị cần lấy)
        subb $'0', %bl         # chuyển ký tự về dạng số (ví dụ '5' → 5)
        notl %edx              # đảo bit edx để tạo mặt nạ
        andl %edx, %eax        # nếu có 2 chữ số thì giữ giá trị trong eax, nếu không thì xóa eax
        notl %edx              # đảo lại giá trị edx về trạng thái cũ
        andl %edx, %ebx        # nếu không có 2 chữ số thì giữ ebx (1 chữ số), nếu có thì xóa ebx
        orl %eax, %ebx         # lựa chọn kết quả hợp lệ
        addl %ebx, %esi        # cộng vào tổng

#mon3
        xorl %eax, %eax        # xóa thanh ghi eax
        xorl %ebx, %ebx        # xóa thanh ghi ebx
        movl $mon3, %ecx       # đưa địa chỉ mon3 vào ecx
        movb (%ecx), %al       # đọc ký tự đầu tiên vào al
        movb 1(%ecx), %bl      # đọc ký tự thứ hai vào bl
        subb $'0', %al         # trừ ký tự '0' để lấy giá trị số
        movsbl %al, %eax       # mở rộng có dấu thành 32 bit
        subb $'0', %bl         # trừ ký tự '0' để lấy giá trị số
        movsbl %bl, %ebx       # mở rộng có dấu thành 32 bit
        movl %ebx, %edx
        sarl $31, %edx         # kiểm tra nếu không có số thứ hai
        imull $10, %eax        # nhân hàng chục với 10
        addl %ebx, %eax        # cộng thêm hàng đơn vị
        movzbl (%ecx), %ebx    # lưu lại ký tự đầu tiên (nếu chỉ có 1 chữ số thì đây là giá trị cần lấy)
        subb $'0', %bl         # chuyển ký tự về dạng số (ví dụ '5' → 5)
        notl %edx              # đảo bit edx để tạo mặt nạ
        andl %edx, %eax        # nếu có 2 chữ số thì giữ giá trị trong eax, nếu không thì xóa eax
        notl %edx              # đảo lại giá trị edx về trạng thái cũ
        andl %edx, %ebx        # nếu không có 2 chữ số thì giữ ebx (1 chữ số), nếu có thì xóa ebx
        orl %eax, %ebx         # lựa chọn kết quả hợp lệ
        addl %ebx, %esi        # cộng vào tổng

#mon4
        xorl %eax, %eax        # xóa thanh ghi eax
        xorl %ebx, %ebx        # xóa thanh ghi ebx
        movl $mon4, %ecx       # đưa địa chỉ mon4 vào ecx
        movb (%ecx), %al       # đọc ký tự đầu tiên vào al
        movb 1(%ecx), %bl      # đọc ký tự thứ hai vào bl
        subb $'0', %al         # trừ ký tự '0' để lấy giá trị số
        movsbl %al, %eax       # mở rộng có dấu thành 32 bit
        subb $'0', %bl         # trừ ký tự '0' để lấy giá trị số
        movsbl %bl, %ebx       # mở rộng có dấu thành 32 bit
        movl %ebx, %edx
        sarl $31, %edx         # kiểm tra nếu không có số thứ hai
        imull $10, %eax        # nhân hàng chục với 10
        addl %ebx, %eax        # cộng thêm hàng đơn vị
        movzbl (%ecx), %ebx    # lưu lại ký tự đầu tiên (nếu chỉ có 1 chữ số thì đây là giá trị cần lấy)
        subb $'0', %bl         # chuyển ký tự về dạng số (ví dụ '5' → 5)
        notl %edx              # đảo bit edx để tạo mặt nạ
        andl %edx, %eax        # nếu có 2 chữ số thì giữ giá trị trong eax, nếu không thì xóa eax
        notl %edx              # đảo lại giá trị edx về trạng thái cũ
        andl %edx, %ebx        # nếu không có 2 chữ số thì giữ ebx (1 chữ số), nếu có thì xóa ebx
        orl %eax, %ebx         # lựa chọn kết quả hợp lệ
        addl %ebx, %esi        # cộng vào tổng

#Tính trung bình
        movl %esi, %eax        # lưu tổng vào eax
        movl $4, %ebx          # chia cho 4
        xorl %edx, %edx        # xóa edx để lưu số dư
        divl %ebx              # eax = tổng / 4

#Tách hàng chục và hàng đơn vị
        xorl %edx, %edx        # xóa edx để lưu số dư
        movl $10, %ebx         # chia cho 10
        divl %ebx              # eax = hàng chục, edx = hàng đơn vị

        addb $'0', %al         # chuyển sang ký tự ASCII
        addb $'0', %dl         # chuyển sang ký tự ASCII

        movl $result, %edi
        movb %al, (%edi)       # lưu hàng chục
        movb %dl, 1(%edi)      # lưu hàng đơn vị
        movb $'\n', 2(%edi)    # thêm ký tự xuống dòng

#In kết quả
        movl $4, %eax          # 4 - system_write
        movl $1, %ebx          # 1 - STDOUT để in kết quả
        movl $result, %ecx     # địa chỉ chuỗi kết quả
        movl $3, %edx          # in 3 byte (2 số + xuống dòng)
        int $0x80              # gọi hệ thống (in ra màn hình)

#Thoát chương trình
        movl $1, %eax          # 1 - system_exit
        int $0x80              # gọi hệ thống (thoát)
