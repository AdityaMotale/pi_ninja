bits 64
default rel

section .rodata
        help_msg db  "Usage: pi_ninja [options]", 0x0A, 0x0A
                 db  "Options:", 0x0A
                 db  "  h   Show this help message", 0x0A
                 db  "  v   Print version info", 0x0A
                 db  " <n>  Compute up to this number", 0x0A
                 db  0x0A, 0x00

        help_msg_len equ $ - help_msg

section .text
        global _start

_start:
        ; print help msg if no args are provided
        cmp rdi, 0x01
        jle print_help
         
        jmp exit

print_help:
        mov rax, 0x01
        mov rdi, 0x01
        lea rsi, [help_msg]
        mov rdx, help_msg_len
        syscall

        jmp exit

exit:
        mov rax, 0x3C
        xor rdi, rdi
        syscall
