    mov ah, 0x00
    ; VGA mode 0x13
    ; 320x200 256 colors
    mov al, 0x13
    int 0x10

    mov ax, 0xA000
    mov es, ax

    mov bx, 0
loop:
    mov BYTE [es:bx], 0x0B
    inc bx
    cmp bx, 64000
    jb loop

    jmp $

    times 510 - ($-$$) db 0
    dw 0xaa55
