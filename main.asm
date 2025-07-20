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

section .bss
        out_num resb 64            ; 64 bit num
        argc resq 1                ; args count
        argv resq 1                ; pointer to args buf

section .text
        global _start

_start:
        ; pull off argc and argv from stack
        mov rdi, [rsp]            ; rdi = argc
        lea rsi, [rsp + 8]        ; rsi = &argv[0]

        ; persist argc & argv
        mov qword [argc], rdi
        mov qword [argv], rsi
        
        ; print error if `argc != 2`
        cmp rdi, 0x02
        jne error_exit

        mov rbx, [rsi + 8]
        mov al, [rbx]

        ; check if its a command
        cmp al, '-'
        je handle_cmds
        
        jmp calc_pi 

; handle CLI cmds like `-h`, `-v`, etc. and exit the program
handle_cmds:
        mov rbx, qword [argv]
        mov rbx, qword [rbx + 8]
        mov al, [rbx + 1]

        ; print help and exit(0)
        cmp al, 'h'
        je print_help

        ; print version and exit(0)
        cmp al, 'v'
        je print_version

        ; if cmd is invalid -> exit(1)
        jmp error_exit

; calculate the value of pi
calc_pi:
        mov rdi, qword [argv]
        mov rdi, qword [rdi + 8]

        call function_atoi

        mov rdi, rax
        mov rax, 0x3C
        syscall

; Convert ASCII string to a 64-bit integer
;
; Args:
;  rdi - pointer to input buf (null terminated)
;
; Ret:
;  rax - parsed int value
;
; Clobbers:
;  rcx
function_atoi:
        xor rax, rax
        xor rcx, rcx
.loop:
        mov cl, [rdi]

        cmp cl, '0'
        jb .done                   ; < '0' -> Done 

        cmp cl, '9'
        ja .done                   ; > '9' -> Done

        imul rax, rax, 0x0A        ; res *= 10
        sub cl, '0'                ; digit = char - '0'
        add rax, rcx               ; res += digit
        
        inc rdi                    ; inc buf pointer
        jmp .loop
.done:
        ret

error_exit:
        ; print error
        mov rax, 0x01
        mov rdi, 0x01
        lea rsi, [invalid_args]
        mov rdx, invalid_args_len
        syscall

        ; exit w/ error
        mov rax, 0x3C
        mov rdi, 0x01
        syscall

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
