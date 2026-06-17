bits 16
cpu 8086
org 0000h

port_a  equ 80h        ; 8255 pa口：输出数码管段码
port_b  equ 82h        ; 8255 pb口：本实验未使用
port_c  equ 84h        ; 8255 pc口：扫描矩阵键盘
ctrl    equ 86h        ; 8255 控制口

jmp start

; 共阴极数码管段码表：0~f
seg_tab:
    db 3fh, 06h, 5bh, 4fh
    db 66h, 6dh, 7dh, 07h
    db 7fh, 6fh, 77h, 7ch
    db 39h, 5eh, 79h, 71h

; 按键映射表，对应键盘：
; 7  8  9  /
; 4  5  6  x
; 1  2  3  -
; c  0  e  +
key_map:
    db 07h, 08h, 09h, 0fh
    db 04h, 05h, 06h, 0bh
    db 01h, 02h, 03h, 0dh
    db 0ch, 00h, 0eh, 0ah

; 行扫描输出表，pc0~pc3 依次拉低
row_tab:
    db 0eh, 0dh, 0bh, 07h

start:
    cli

    ; 初始化堆栈
    xor ax, ax
    mov ss, ax
    mov sp, 0fffeh

    ; ds 指向当前代码段，方便访问数据表
    mov ax, cs
    mov ds, ax

    ; 初始化 8255：
    ; pa 输出，pb 输出，pc高4位输入，pc低4位输出，方式0
    mov dx, ctrl
    mov al, 88h
    out dx, al

    ; 数码管初始熄灭
    mov dx, port_a
    mov al, 00h
    out dx, al

    ; pc低4位先全部置1，避免默认拉低某一行
    mov dx, port_c
    mov al, 0fh
    out dx, al

main:
    ; 扫描键盘
    call get_key
    cmp al, 0ffh
    je main

    ; 有按键则显示
    call show_key
    call delay

    jmp main

get_key:
    push bx
    push cx
    push dx
    push si

    ; bl 保存当前行号：0~3
    mov bl, 0
    mov si, row_tab
    mov cx, 4

scan_row:
    ; 输出当前行扫描码到 pc低4位
    mov al, [si]
    mov dx, port_c
    out dx, al

    call short_delay

    ; 读取 pc高4位列状态
    in al, dx
    and al, 0f0h

    ; 如果 pc4~pc7 全为1，说明当前行没有按键
    cmp al, 0f0h
    jne found_row

    inc si
    inc bl
    loop scan_row

    ; 四行都没有按键，返回 ffh
    mov al, 0ffh
    jmp get_key_end

found_row:
    ; bh 保存列号：0~3
    mov bh, 0

    ; 判断哪一列被拉低
    test al, 10h
    jz found_col

    inc bh
    test al, 20h
    jz found_col

    inc bh
    test al, 40h
    jz found_col

    inc bh
    test al, 80h
    jz found_col

    mov al, 0ffh
    jmp get_key_end

found_col:
    ; 按键序号 = 行号 * 4 + 列号
    mov al, bl
    shl al, 1
    shl al, 1
    add al, bh

    ; 查 key_map，得到要显示的数值 0~f
    mov bx, key_map
    xlat

get_key_end:
    ; 暂存返回值
    mov ah, al

    ; 扫描结束后恢复 pc低4位为1111
    mov dx, port_c
    mov al, 0fh
    out dx, al

    ; 恢复返回值到 al
    mov al, ah

    pop si
    pop dx
    pop cx
    pop bx
    ret

show_key:
    push bx
    push dx

    ; al 是按键值，查段码表
    mov bx, seg_tab
    xlat

    ; 输出到数码管
    mov dx, port_a
    out dx, al

    pop dx
    pop bx
    ret

short_delay:
    push cx
    mov cx, 0100h

short_delay_loop:
    loop short_delay_loop

    pop cx
    ret

delay:
    push cx
    mov cx, 4000h

delay_loop:
    loop delay_loop

    pop cx
    ret