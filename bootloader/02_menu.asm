; A bootable x86 program. Demonstrates:
;   - Printing a hello-world message via BIOS teletype (int 0x10, ah=0x0E)
;   - Screen clearing via video mode reset
;   - Keyboard input, blocking read (int 0x16, ah=0x00)
;   - A simple dispatch loop based on user choice


BITS 16
ORG 0x7C00

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; --- Hello World splash screen ---
    call clear_screen
    mov si, hello_msg
    call print_string
    call wait_for_key
    ; ----------------------------------

main_menu:
    call clear_screen
    mov si, title_msg
    call print_string
    mov si, menu_msg
    call print_string

    mov ah, 0x00              ; blocking key read; AL = ASCII of key
    int 0x16

    cmp al, '1'
    je option_one
    cmp al, '2'
    je option_two
    cmp al, '3'
    je option_reboot
    jmp main_menu              ; unrecognized key -> redraw

option_one:
    call clear_screen
    mov si, opt1_msg
    call print_string
    call wait_for_key
    jmp main_menu

option_two:
    call clear_screen
    mov si, opt2_msg
    call print_string
    call wait_for_key
    jmp main_menu

option_reboot:
    call clear_screen
    mov si, reboot_msg
    call print_string
    mov cx, 0xFFFF
.delay:
    loop .delay
    mov al, 0xFE               ; pulse CPU reset line via kbd controller
    out 0x64, al
    jmp $

; ---- print_string: SI -> null-terminated string ----
print_string:
    push ax
.loop:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp .loop
.done:
    pop ax
    ret

; ---- clear_screen: reset video mode 3 (80x25 text) ----
clear_screen:
    push ax
    mov ax, 0x0003
    int 0x10
    pop ax
    ret

; ---- wait_for_key: prompt + blocking read ----
wait_for_key:
    push ax
    push si
    mov si, anykey_msg
    call print_string
    mov ah, 0x00
    int 0x16
    pop si
    pop ax
    ret

; ---- Data (kept short: every byte counts in 512) ----
hello_msg   db "Hello, World! (from the bootloader)", 13, 10, 0
title_msg   db "== MY-OS Boot Menu ==", 13, 10, 13, 10, 0
menu_msg    db "1) Message  2) About  3) Reboot", 13, 10, "> ", 0
opt1_msg    db "Real mode. No OS. This IS the system.", 13, 10, 0
opt2_msg    db "512-byte NASM program loaded by BIOS", 13, 10
            db "at 0x7C00, no OS underneath.", 13, 10, 0
reboot_msg  db "Rebooting...", 13, 10, 0
anykey_msg  db 13, 10, "[press a key]", 0

times 510 - ($ - $$) db 0
dw 0xAA55
