    org 0x7C00
%define WIDTH 320
%define HEIGHT 200
%define COLUMNS 40
%define ROWS 25

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

%define BACKGROUND_COLOR COLOR_BLACK

%define BALL_WIDTH 16
%define BALL_HEIGHT 16
%define BALL_VELOCITY 2
%define BALL_COLOR COLOR_YELLOW

%define BAR_INITIAL_Y 50
%define BAR_HEIGHT 3
%define BAR_COLOR COLOR_LIGHTBLUE
%define BAR_VELOCITY 3

%define VGA_OFFSET 0xA000

%define SCORE_DIGIT_COUNT 5

struc GameState
  .running: resb 1
  .ball_x: resw 1
  .ball_y: resw 1
  .ball_dx: resw 1
  .ball_dy: resw 1
  .bar_x: resw 1
  .bar_y: resw 1
  .bar_dx: resw 1
  .bar_len: resw 1
  .score_sign resb SCORE_DIGIT_COUNT
endstruc

entry:
    ; VGA mode 0x13
    ; 320x200 256 colors
    mov ax, 0x13
    int 0x10

    xor ax, ax
    mov es, ax
    mov ds, ax
    mov cx, GameState_size
    mov si, initial_game_state
    mov di, game_state
    rep movsb

    ;; reprogramming channel 0 of PIT to get 60 fps rendering
    ;; for reference https://wiki.osdev.org/Programmable_Interval_Timer
    ;; reload value = 1193182 Hz / 60 Hz = 19886 = 0x4DAE

    ;; writing 0b00110100 to I/O-port 0x43 (PIT command register)
    ;;           00...... channel 0
    ;;           ..11.... access mode: lobyte/hibyte
    ;;           ....010. mode 2 (rate generator)
    ;;           .......0 16-bit binary mode
    ;; then writing the reload value 0x4DAE to I/O-port 0x40 (channel 0 data port)
    ;; in two steps (low byte, then high byte)

    cli
    mov al, 0b00110100
    out 0x43, al
    mov al, 0xAE
    out 0x40, al
    mov al, 0x4D
    out 0x40, al
    sti

    mov dword [0x0070], draw_frame
.loop:
    hlt
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

    cmp al, 'f'
    jz entry

    jmp .loop
.swipe_left:
    mov word [game_state + GameState.bar_dx], - BAR_VELOCITY
    jmp .loop
.swipe_right:
    mov word [game_state + GameState.bar_dx], BAR_VELOCITY
    jmp .loop
.toggle_pause:
    not byte [game_state + GameState.running]
    jmp .loop

draw_frame:
    pusha

    xor ax, ax

    mov es, ax
    mov ah, 0x13
    mov bx, 0x0064
    mov cl, SCORE_DIGIT_COUNT
    xor dx, dx
    mov bp, game_state + GameState.score_sign
    int 10h

    mov ax, VGA_OFFSET
    mov es, ax

    test byte [game_state + GameState.running], 1
    jz stop_state

running_state:
    mov al, BACKGROUND_COLOR
    call fill_bar
    call fill_ball

    ;; if (ball_x <= 0 || ball_x >= WIDTH - BALL_WIDTH) {
    ;;   ball_dx = -ball_dx;
    ;; }
    mov ax, word [game_state + GameState.ball_x]
    cmp ax, 0
    jle .neg_ball_dx

    cmp ax, WIDTH - BALL_WIDTH
    jl .ball_x_col_end
.neg_ball_dx:
    neg word [game_state + GameState.ball_dx]
.ball_x_col_end:

    ;; if (ball_y >= HEIGHT - BALL_HEIGHT) {
    ;;   gameOver();
    ;; } else if (ball_y <= 0) {
    ;;   ball_dy = -ball_dy;
    ;; }
    mov ax, word [game_state + GameState.ball_y]
    cmp ax, HEIGHT - BALL_HEIGHT
    jge .game_over

    cmp ax, 0
    jg .ball_y_col_end

    neg word [game_state + GameState.ball_dy]
.ball_y_col_end:

    ;; if (bar_x <= 0 || bar_x >= WIDTH - BAR_WIDTH) {
    ;;   bar_dx = -bar_dx;
    ;;   bar_x = snap_to(side_it_collided_with);
    ;; }
    xor ax, ax
    cmp word [game_state + GameState.bar_x], ax
    jle .neg_bar_dx

    mov ax, WIDTH
    sub ax, word [game_state + GameState.bar_len]
    cmp word [game_state + GameState.bar_x], ax
    jl .bar_x_col

.neg_bar_dx:
    neg word [game_state + GameState.bar_dx]
    mov word [game_state + GameState.bar_x], ax
.bar_x_col:


;;; Kebab Begin ------------------------------
    ;; bar_x <= ball_x && ball_x - bar_x <= BAR_WIDTH - BALL_WIDTH
    mov bx, word [game_state + GameState.ball_x]
    cmp word [game_state + GameState.bar_x], bx
    jg .unkebab

    sub bx, word [game_state + GameState.bar_x]
    mov ax, word [game_state + GameState.bar_len]
    sub ax, BALL_WIDTH
    cmp bx, ax
    jg .unkebab

    ; ball_y > bar_y => ignore
    mov ax, [game_state + GameState.bar_y]
    cmp word [game_state + GameState.ball_y], ax
    jg .kebab_end

    ; ball_y >= bar_y - BALL_HEIGHT / 2 => kebab
    sub ax, BALL_HEIGHT / 2
    cmp word [game_state + GameState.ball_y], ax
    jge .kebab

    ; ball_y >= bar_y - BALL_HEIGHT => bounce
    sub ax, BALL_HEIGHT / 2
    cmp word [game_state + GameState.ball_y], ax
    jl .kebab_end

.bounce:
    mov word [game_state + GameState.ball_dy], -BALL_VELOCITY
    mov word [game_state + GameState.ball_dx], BALL_VELOCITY
    mov ax, word [game_state + GameState.bar_dx]
    test ax, ax
    jns .score_point
    neg word [game_state + GameState.ball_dx]
    jmp .score_point
.kebab:
    mov word [game_state + GameState.ball_dy], 0
    ;; Fall through
.score_point:
    mov di, game_state + GameState.score_sign + SCORE_DIGIT_COUNT - 1
.loop:
    inc byte [di]
    cmp byte [di], '9'
    jle .end
    mov byte [di], '0'
    dec di
    jnz .loop
.end:

    cmp word [game_state + GameState.bar_len], 20
    jle .kebab_end
    dec word [game_state + GameState.bar_len]
    jmp .kebab_end

.unkebab:
    cmp word [game_state + GameState.ball_dy], 0
    jnz .kebab_end
    mov word [game_state + GameState.ball_dy], -BALL_VELOCITY
.kebab_end:
;;; Kebab End ------------------------------

    ;; ball_x += ball_dx
    mov ax, [game_state + GameState.ball_dx]
    add [game_state + GameState.ball_x], ax

    ;; ball_y += ball_dy
    mov ax, [game_state + GameState.ball_dy]
    add [game_state + GameState.ball_y], ax

    ;; bar_x += bar_dx
    mov ax, [game_state + GameState.bar_dx]
    add [game_state + GameState.bar_x], ax

    mov al, BAR_COLOR
    call fill_bar

    mov al, BALL_COLOR
    call fill_ball

    jmp stop_state
.game_over:
    xor ax, ax
    mov es, ax
    mov ah, 0x13
    mov bx, 0x0064
    ; ch = 0 ; cl = game_over_sign_len
    mov cx, game_over_sign_len
    ; dh = ROWS / 2 ; dl = COLUMNS / 2 - game_over_sign_len / 2
    mov dx, (ROWS / 2) << 8 | (COLUMNS / 2 - game_over_sign_len / 2)
    mov bp, game_over_sign
    int 10h
    mov byte [game_state + GameState.running], 0

stop_state:
    popa
    iret

fill_bar:
    mov cx, word [game_state + GameState.bar_len]
    mov bx, BAR_HEIGHT
    mov si, game_state + GameState.bar_x
    jmp fill_rect

fill_ball:
    mov cx, BALL_WIDTH
    mov bx, BALL_HEIGHT
    mov si, game_state + GameState.ball_x

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

initial_game_state:
istruc GameState
  at GameState.running, db 1
  at GameState.ball_x, dw 30
  at GameState.ball_y, dw 30
  at GameState.ball_dx, dw BALL_VELOCITY
  at GameState.ball_dy, dw -BALL_VELOCITY
  at GameState.bar_x, dw 10
  at GameState.bar_y, dw HEIGHT - BAR_INITIAL_Y
  at GameState.bar_dx, dw BAR_VELOCITY
  at GameState.bar_len, dw 100
  at GameState.score_sign, times SCORE_DIGIT_COUNT db '0'
iend

game_over_sign: db "Game Over"
game_over_sign_len equ $ - game_over_sign

%assign sizeOfProgram $ - $$
%warning Size of the program: sizeOfProgram bytes

    times 510 - ($-$$) db 0
game_state:
    dw 0xaa55

    %if $ - $$ != 512
        %fatal Resulting size is not 512
    %endif
