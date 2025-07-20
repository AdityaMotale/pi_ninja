#!/usr/bin/env bash

if ! nasm -f elf64 main.asm -o main.o 2>nasm_error.log; then
    echo "[nasm]  " >&2
    cat nasm_error.log >&2
    exit 1
fi

if ! ld -o main main.o 2>ld_error.log; then
    echo "[ld]  " >&2
    cat ld_error.log >&2
    exit 1
fi

rm -f nasm_error.log ld_error.log
echo " "

