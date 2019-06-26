    org 0x7C00
%define WIDTH 320
%define HEIGHT 200

%define COLOR_BLACK 0
%define COLOR_BLUE 1
%define COLOR_GREEN 2
%define COLOR_CYAN 3
%define COLOR_RED 4
%define COLOR_MAGENTA 5
%define COLOR_BROWN 6
%define COLOR_LIGHTGRAY 7
%define COLOR_DARKGRAY 8
%define COLOR_LIGHTBLUE 9
%define COLOR_LIGHTGREEN 10
%define COLOR_LIGHTCYAN 11
%define COLOR_LIGHTRED 12
%define COLOR_LIGHTMAGENTA 13
%define COLOR_YELLOW 14
%define COLOR_WHITE 15

%define BACKGROUND_COLOR COLOR_DARKGRAY

%define BALL_WIDTH 10
%define BALL_HEIGHT 10
%define BALL_COLOR COLOR_YELLOW

%define BAR_WIDTH 100
%define BAR_HEIGHT BALL_HEIGHT
%define BAR_COLOR COLOR_LIGHTBLUE

entry:
    mov ah, 0x00
    ; VGA mode 0x13
    ; 320x200 256 colors
    mov al, 0x13
    int 0x10

    mov ch, BACKGROUND_COLOR
    call fill_screen

    xor ax, ax
    mov es, ax
    mov word [es:0x0070], draw_frame
    mov word [es:0x0072], 0x00

.loop:
    mov ah, 0x1
    int 0x16
    jz .loop

    mov ah, 0x0
    int 0x16

    cmp al, 'a'
    jz .swipe_left

    cmp al, 'd'
    jz .swipe_right

    jmp .loop
.swipe_left:
    mov word [bar_dx], -10
    jmp .loop
.swipe_right:
    mov word [bar_dx], 10
    jmp .loop


draw_frame:
    pusha

    mov ax, 0x0000
    mov ds, ax

    mov ax, 0xA000
    mov es, ax

    mov word [rect_width], BALL_WIDTH
    mov word [rect_height], BALL_HEIGHT
    mov ax, word [ball_x]
    mov word [rect_x], ax
    mov ax, word [ball_y]
    mov word [rect_y], ax
    mov ch, BACKGROUND_COLOR
    call fill_rect

    mov word [rect_width], BAR_WIDTH
    mov word [rect_height], BAR_HEIGHT
    mov ax, [bar_x]
    mov [rect_x], ax
    mov word [rect_y], HEIGHT - 20
    mov ch, BACKGROUND_COLOR
    call fill_rect

    ;; if (ball_x <= 0 || ball_x >= WIDTH - BALL_WIDTH) {
    ;;   ball_dx = -ball_dx;
    ;; }
    cmp word [ball_x], 0
    jle .neg_ball_dx

    cmp word [ball_x], WIDTH - BALL_WIDTH
    jge .neg_ball_dx

    jmp .ball_x_col
.neg_ball_dx:
    neg word [ball_dx]
.ball_x_col:

    ;; if (ball_y <= 0 || ball_y >= HEIGHT - BALL_HEIGHT) {
    ;;   ball_dy = -ball_dy;
    ;; }
    cmp word [ball_y], 0
    jle .neg_ball_dy

    cmp word [ball_y], HEIGHT - BALL_HEIGHT
    jge .neg_ball_dy

    jmp .ball_y_col
.neg_ball_dy:
    neg word [ball_dy]
.ball_y_col:

    ;; if (bar_x <= 0 || bar_x >= WIDTH - BAR_WIDTH) {
    ;;   bar_dx = -bar_dx;
    ;; }
    cmp word [bar_x], 0
    jle .neg_bar_dx

    cmp word [bar_x], WIDTH - BAR_WIDTH
    jge .neg_bar_dx

    jmp .bar_x_col
.neg_bar_dx:
    neg word [bar_dx]
.bar_x_col:

    ;; ball_x += ball_dx
    mov ax, [ball_x]
    add ax, [ball_dx]
    mov [ball_x], ax

    ;; ball_y += ball_dy
    mov ax, [ball_y]
    add ax, [ball_dy]
    mov [ball_y], ax

    ;; bar_x += bar_dx
    mov ax, [bar_x]
    add ax, [bar_dx]
    mov [bar_x], ax

    mov word [rect_width], BALL_WIDTH
    mov word [rect_height], BALL_HEIGHT
    mov ax, word [ball_x]
    mov word [rect_x], ax
    mov ax, word [ball_y]
    mov word [rect_y], ax
    mov ch, BALL_COLOR
    call fill_rect

    mov word [rect_width], BAR_WIDTH
    mov word [rect_height], BAR_HEIGHT
    mov ax, [bar_x]
    mov [rect_x], ax
    mov word [rect_y], HEIGHT - 20
    mov ch, BAR_COLOR
    call fill_rect

    popa
    iret

fill_screen:
    ;; ch - color
    pusha

    mov ax, 0xA000
    mov es, ax

;; TODO(#9): could be rewritten with rep stuff
    xor bx, bx
.loop:
    mov BYTE [es: bx], ch
    inc bx
    cmp bx, WIDTH * HEIGHT
    jb .loop

    popa
    ret

fill_rect:
    ;; ch - color

    mov ax, 0x0000
    mov ds, ax

    mov word [y], 0
.y:
    mov word [x], 0
.x:
    mov ax, WIDTH
    mov bx, [y]
    add bx, [rect_y]
    mul bx
    mov bx, ax
    add bx, [x]
    add bx, [rect_x]
    mov BYTE [es: bx], ch

    inc word [x]
    mov dx, [rect_width]
    cmp [x], dx
    jb .x

    inc word [y]
    mov dx, [rect_height]
    cmp [y], dx
    jb .y

    ret

x: dw 0xcccc
y: dw 0xcccc

;; TODO(#10): Introduce bar at the bottom that is controlled by the player
ball_x: dw 30
ball_y: dw 30
ball_dx: dw 2
ball_dy: dw (-2)

bar_x: dw 10
bar_y: dw 0
bar_dx: dw 10

rect_x: dw 0xcccc
rect_y: dw 0xcccc
rect_width: dw 0xcccc
rect_height: dw 0xcccc

    times 510 - ($-$$) db 0
    dw 0xaa55

    %if $ - $$ != 512
        %fatal Resulting size is not 512
    %endif
