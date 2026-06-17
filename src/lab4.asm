bits 16
org 0000h

jmp start

ch0       equ 00h
ch1       equ 02h
pit_ctrl  equ 06h

pic_cmd   equ 08h
pic_data  equ 0ah

led_port  equ 10h
seg_port  equ 18h

int_type  equ 20h

times 0400h - ($ - $$) db 0

step db 0

seg_table:
    db 06h, 5bh, 4fh, 66h, 6dh, 7dh, 07h, 7fh

led_table:
    db 0feh, 0fdh, 0fbh, 0f7h, 0efh, 0dfh, 0bfh, 07fh

start:
    cli

    xor ax, ax
    mov ss, ax
    mov sp, 0fffeh

    mov ax, cs
    mov ds, ax

    mov byte [step], 0

    xor ax, ax
    mov es, ax

    mov ax, timer_isr
    mov word [es:int_type * 4], ax

    mov ax, cs
    mov word [es:int_type * 4 + 2], ax

    mov dx, led_port
    mov al, 0ffh
    out dx, al

    mov dx, seg_port
    mov al, 00h
    out dx, al

    ; 初始化 8259A
    mov dx, pic_cmd
    mov al, 13h
    out dx, al

    mov dx, pic_data
    mov al, 20h
    out dx, al

    mov al, 01h
    out dx, al

    mov al, 0ffh
    out dx, al

    ; 初始化 8253 通道0：1MHz / 1000 = 1kHz
    mov dx, pit_ctrl
    mov al, 34h
    out dx, al

    mov dx, ch0
    mov al, 0e8h
    out dx, al
    mov al, 03h
    out dx, al

    ; 初始化 8253 通道1：1kHz / 1000 = 1Hz
    mov dx, pit_ctrl
    mov al, 74h
    out dx, al

    mov dx, ch1
    mov al, 0e8h
    out dx, al
    mov al, 03h
    out dx, al

    mov dx, pic_cmd
    mov al, 20h
    out dx, al

    mov dx, pic_data
    mov al, 0feh
    out dx, al

    sti

main:
    hlt
    jmp main

timer_isr:
    push ax
    push bx
    push dx
    push ds

    push cs
    pop ds

    mov al, [step]
    cmp al, 8
    jae finish_show

    xor bh, bh
    mov bl, al

    mov al, [led_table + bx]
    mov dx, led_port
    out dx, al

    mov al, [seg_table + bx]
    mov dx, seg_port
    out dx, al

    inc byte [step]
    jmp send_eoi

finish_show:
    mov dx, led_port
    mov al, 0ffh
    out dx, al

    mov dx, seg_port
    mov al, 00h
    out dx, al

    mov dx, pic_data
    mov al, 0ffh
    out dx, al

send_eoi:
    mov dx, pic_cmd
    mov al, 20h
    out dx, al

    pop ds
    pop dx
    pop bx
    pop ax
    iret