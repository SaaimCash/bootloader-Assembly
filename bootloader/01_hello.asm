; A minimal x86 boot sector: prints "Hello, World!" and halts.
;
; The BIOS loads the first 512-byte sector of a bootable disk to
; physical address 0x7C00, then jumps to it in 16-bit real mode.
; There is no OS here.

BITS 16                 
ORG 0x7C00               ; BIOS loads us at this address

start:
    ; Setting up segment registers. On boot, these are unreliable, so
    ; we explicitly zero them and set up a stack below our code.
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00        ; stack grows down from our own load address

    mov si, msg           ; SI is a pointer to our null-terminated string

.print_loop:
    lodsb                 ; load byte at [SI] into AL, increment SI
    cmp al, 0             ; Is the byte 0 (null terminator)?
    je .halt              ; If yes, jump to .halt
    mov ah, 0x0E           ; BIOS teletype function: print char in AL
    mov bh, 0x00            ; page number
    mov bl, 0x07            ; text attribute (light grey on black)
    int 0x10                ; BIOS video interrupt
    jmp .print_loop

.halt:
    cli                     ; disable interrupts
    hlt                     ; halt the CPU
    jmp .halt               ; in case of NMI, halt again

msg db "Hello, World! (from the bootloader)", 0  

times 510 - ($ - $$) db 0
dw 0xAA55

