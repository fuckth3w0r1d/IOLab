section .text
    global start

start:
    mov  dx, 0x0008
    in   al, dx
    mov  dx, 0x000C
    out  dx, al
    jmp  start