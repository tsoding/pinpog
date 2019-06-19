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

    mov ax, 0x0000
    mov ds, ax

    mov ax, 0xA000
    mov es, ax

    mov ch, 0x00
    call draw_ball

;; TODO(#2): make ball bounce of the walls
    ;; if (ball_x <= 0 || ball_x >= WIDTH - BALL_WIDTH) {
    ;;   ball_dx = -ball_dx;
    ;; }
    cmp word [ball_x], 0
    jle .neg_dx

    cmp word [ball_x], WIDTH - BALL_WIDTH
    jge .neg_dx

    jmp .horcol_end
.neg_dx:
    neg word [ball_dx]
.horcol_end:

    ;; if (ball_y <= 0 || ball_y >= HEIGHT - BALL_HEIGHT) {
    ;;   ball_dy = -ball_dy;
    ;; }
    cmp word [ball_y], 0
    jle .neg_dy

    cmp word [ball_y], HEIGHT - BALL_HEIGHT
    jge .neg_dy

    jmp .vercol_end
.neg_dy:
    neg word [ball_dy]
.vercol_end:

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

ball_x: dw 30
ball_y: dw 30
ball_dx: dw 2
ball_dy: dw (-2)

    times 510 - ($-$$) db 0
    dw 0xaa55
