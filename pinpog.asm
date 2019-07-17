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
%define BALL_VELOCITY 4
%define BALL_COLOR COLOR_YELLOW

%define BAR_Y 50
%define BAR_HEIGHT BALL_HEIGHT
%define BAR_COLOR COLOR_LIGHTBLUE

%define VGA_OFFSET 0xA000

%define SCORE_DIGIT_COUNT 5

entry:
    xor ah, ah
    ; VGA mode 0x13
    ; 320x200 256 colors
    mov al, 0x13
    int 0x10

    mov ax, VGA_OFFSET
    mov es, ax
    mov al, BACKGROUND_COLOR
    call fill_screen

    mov dword [0x0070], draw_frame

.loop:
    mov ah, 0x1
    int 0x16
    jz .loop

    xor ah, ah
    int 0x16

    cmp al, 'a'
    jz .swipe_left

    cmp al, 'd'
    jz .swipe_right

    cmp al, ' '
    jz .toggle_pause

    jmp .loop
.swipe_left:
    mov word [bar_dx], -10
    jmp .loop
.swipe_right:
    mov word [bar_dx], 10
    jmp .loop
.toggle_pause:
    mov ax, [state]
    cmp ax, pause_state
    jz .unpause
    mov word [state], pause_state
    jmp .loop
.unpause:
    mov word [state], running_state
    jmp .loop

draw_frame:
    pusha

    xor ax, ax
    mov ds, ax

    mov si, SCORE_DIGIT_COUNT
    mov ax, [score_value]
    mov cx, 10
.loop:
    xor dx, dx
    div cx
    add dl, '0'
    dec si
    mov byte [score_svalue + si], dl
    jnz .loop

;; TODO(#42): Background and foreground colors of score_sign don't fit the game
    xor ax, ax
    mov es, ax
    mov ax, 0x1300
    mov bx, 0x0064
    mov cl, [score_sign_len]
    xor dx, dx
    mov bp, score_sign
    int 10h

    mov ax, VGA_OFFSET
    mov es, ax

    jmp [state]

running_state:
    mov al, BACKGROUND_COLOR

    mov cx, BALL_WIDTH
    mov bx, BALL_HEIGHT
    mov si, ball_x
    call fill_rect

    movzx cx, byte [bar_len]
    mov bx, BAR_HEIGHT
    mov si, bar_x
    call fill_rect

    ;; if (ball_x <= 0 || ball_x >= WIDTH - BALL_WIDTH) {
    ;;   ball_dx = -ball_dx;
    ;; }
    cmp word [ball_x], 0
    jle .neg_ball_dx

    cmp word [ball_x], WIDTH - BALL_WIDTH
    jl .ball_x_col
.neg_ball_dx:
    neg word [ball_dx]
.ball_x_col:

    ;; if (ball_y <= 0 || ball_y >= HEIGHT - BALL_HEIGHT) {
    ;;   ball_dy = -ball_dy;
    ;; }
    cmp word [ball_y], 0
    jle .neg_ball_dy

    cmp word [ball_y], HEIGHT - BALL_HEIGHT
    jge .game_over

    ;; bar_x <= ball_x && ball_x - bar_x <= BAR_WIDTH - BALL_WIDTH
    mov bx, word [ball_x]
    cmp word [bar_x], bx
    jg .ball_y_col

    sub bx, word [bar_x]
    movzx ax, byte [bar_len]
    sub ax, BALL_WIDTH
    cmp bx, ax
    jg .ball_y_col

    ;; ball_y >= HEIGHT - BALL_HEIGHT - BAR_Y
    cmp word [ball_y], HEIGHT - BALL_HEIGHT - BAR_Y
    jge .score_point
    jmp .ball_y_col
.game_over:
    mov word [state], game_over_state
    popa
    iret
.score_point:
    inc word [score_value]
    ;; TODO: bar_len can potentially become negative
    sub byte [bar_len], 1
.neg_ball_dy:
    neg word [ball_dy]
.ball_y_col:

    ;; TODO(#17): Sometimes the bar gets stuck in a wall

    ;; if (bar_x <= 0 || bar_x >= WIDTH - BAR_WIDTH) {
    ;;   bar_dx = -bar_dx;
    ;; }
    cmp word [bar_x], 0
    jle .neg_bar_dx

    movzx ax, byte [bar_len]
    neg ax
    add ax, WIDTH
    cmp word [bar_x], ax
    jge .neg_bar_dx

    jmp .bar_x_col
.neg_bar_dx:
    neg word [bar_dx]
.bar_x_col:

    ;; ball_x += ball_dx
    mov ax, [ball_dx]
    add [ball_x], ax

    ;; ball_y += ball_dy
    mov ax, [ball_dy]
    add [ball_y], ax

    ;; bar_x += bar_dx
    mov ax, [bar_dx]
    add [bar_x], ax

    mov cx, BALL_WIDTH
    mov bx, BALL_HEIGHT
    mov si, ball_x
    mov al, BALL_COLOR
    call fill_rect

    movzx cx, byte [bar_len]
    mov bx, BAR_HEIGHT
    mov si, bar_x
    mov al, BAR_COLOR
    call fill_rect

pause_state:
    popa
    iret

;; TODO(#23): no proper way to restart the game when you are in game over state
;; TODO(#24): there is no "Game Over" sign in the Game Over state
;; TODO(#43): the score sign is flickering in Game Over state
game_over_state:
    mov al, COLOR_RED
    call fill_screen
    popa
    iret

fill_screen:
    ;; ch - color
    pusha

    xor di, di
    mov cx, WIDTH * HEIGHT
    rep stosb

    popa
    ret

fill_rect:
    ;; al - color
    ;; cx - width
    ;; bx - height
    ;; si - pointer to ball_x or bar_x

    ; di = rect_y * WIDTH + rect_x
    imul di, [si + 2], WIDTH
    add di, [si]

.row:
    push cx
    rep stosb
    pop cx
    sub di, cx
    add di, WIDTH
    dec bx
    jnz .row

    ret

;; TODO(#18): Game does not keep track of the score
;;   Every bar hit should give you points
;; TODO(#19): Game does not get harder over time
state: dw running_state
ball_x: dw 30
ball_y: dw 30
ball_dx: dw BALL_VELOCITY
ball_dy: dw -BALL_VELOCITY

bar_x: dw 10
bar_y: dw HEIGHT - BAR_Y
bar_dx: dw 10
bar_len: db 100

score_value: dw 0

;; sign = label + svalue
score_sign: db "Score: "
score_svalue: times SCORE_DIGIT_COUNT db 0
score_sign_len: db ($ - score_sign)

%assign sizeOfProgram $ - $$
%warning Size of the program: sizeOfProgram bytes

    times 510 - ($-$$) db 0
    dw 0xaa55

    %if $ - $$ != 512
        %fatal Resulting size is not 512
    %endif
