bits 16
org 0000h

ch1   equ 02h
ch2   equ 04h
ctrl  equ 06h

start:
    ; 初始化通道1：方式3，1khz方波
    ; 控制字：01 11 011 0 = 76h
    mov dx, ctrl
    mov al, 76h
    out dx, al

    mov dx, ch1
    mov al, 0e8h      ; 1000 = 03e8h，先写低字节 e8h
    out dx, al
    mov al, 03h       ; 再写高字节 03h
    out dx, al

    ; 初始化通道2：方式2，1khz负脉冲
    ; 控制字：10 11 010 0 = b4h
    mov dx, ctrl
    mov al, 0b4h
    out dx, al

    mov dx, ch2
    mov al, 0e8h      ; 低字节
    out dx, al
    mov al, 03h       ; 高字节
    out dx, al

here:
    jmp here