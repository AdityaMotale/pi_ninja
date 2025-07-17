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

        invalid_args db "[Err]: Invalid arguments", 0x0A
                     db "Use `-h` for help", 0x0A

        invalid_args_len equ $ - invalid_args

        version_info db "Pi(π)_Ninja V-0.1", 0x0A
        version_info_len equ $ - version_info

section .text
        global _start

_start:
        ; pull off argc and argv from stack
        mov     rdi, [rsp]         ; rdi = argc
        lea     rsi, [rsp + 8]     ; rsi = &argv[0]
        
        ; print error msg if no `argc != 2`
        cmp rdi, 0x02
        jne print_error

        ; obtain pointer to argv[1]
        mov rbx, [rsi + 8]
        
        ; check if its a command
        mov al, [rbx]
        cmp al, '-'
        jne atoi

        mov al, [rbx + 1]
        
        cmp al, 'h'
        je print_help

        cmp al, 'v'
        je print_version

        ; no matching cmd found
        jmp print_error

; parse ascii to integer
atoi:
        xor rax, rax
        xor rcx, rcx
.loop:
        mov cl, [rbx]

        cmp cl, '0'
        jb .done

        cmp cl, '9'
        ja .done

        imul rax, rax, 0x0A
        sub cl, '0'
        add rax, rcx
        inc rbx

        jmp .loop
.done:
        mov rdi, rax
        and rdi, 0xFF

        jmp calc_pi
calc_pi:
        jmp exit

print_error:
        mov rax, 0x01
        mov rdi, 0x01
        lea rsi, [invalid_args]
        mov rdx, invalid_args_len
        syscall

        jmp exit

print_version:
        mov rax, 0x01
        mov rdi, 0x01
        lea rsi, [version_info]
        mov rdx, version_info_len
        syscall

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
