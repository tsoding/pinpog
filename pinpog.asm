    org 0x7C00
%define WIDTH 320
%define HEIGHT 200

%define BALL_WIDTH 10
%define BALL_HEIGHT 10

    mov ah, 0x00
    ; VGA mode 0x13
    ; 320x200 256 colors
    mov al, 0x13
    int 0x10

    xor ax, ax
    mov es, ax
    mov word [es:0x0070], draw_frame
    mov word [es:0x0072], 0x00

    jmp $

draw_frame:
    pusha

    mov ax, 0xA000
    mov es, ax

    mov ch, 0x00
    call draw_ball

;; TODO(#2): make ball bounce of the walls
    mov ax, [ball_x]
    add ax, [ball_dx]
    mov [ball_x], ax

    mov ax, [ball_y]
    add ax, [ball_dy]
    mov [ball_y], ax

;; TODO(#3): redrawing the ball flickers a lot
    mov ch, 0x0A
    call draw_ball

    popa
    iret

draw_ball:
    ;; ch - color

    mov ax, 0x0000
    mov ds, ax

    mov word [y], 0
.y:
    mov word [x], 0
.x:
    mov ax, WIDTH
    mov bx, [y]
    add bx, [ball_y]
    mul bx
    mov bx, ax
    add bx, [x]
    add bx, [ball_x]
    mov BYTE [es: bx], ch

    inc word [x]
    cmp word [x], BALL_WIDTH
    jb .x

    inc word [y]
    cmp word [y], BALL_HEIGHT
    jb .y

    ret

x: dw 0xcccc
y: dw 0xcccc

ball_x: dw 0
ball_y: dw 0
ball_dx: dw 1
ball_dy: dw 1

    times 510 - ($-$$) db 0
    dw 0xaa55
